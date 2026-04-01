import json
import os
import boto3
import subprocess
import urllib.parse
from datetime import datetime, timezone

s3 = boto3.client("s3")

CLEAN_BUCKET = os.environ["CLEAN_BUCKET"]
QUARANTINE_BUCKET = os.environ["QUARANTINE_BUCKET"]
SCAN_RESULTS_BUCKET = os.environ["SCAN_RESULTS_BUCKET"]

def lambda_handler(event, context):
    for record in event["Records"]:
        body = json.loads(record["body"])

        for s3_record in body["Records"]:
            source_bucket = s3_record["s3"]["bucket"]["name"]
            source_key = urllib.parse.unquote_plus(s3_record["s3"]["object"]["key"])

            local_path = f"/tmp/{source_key.split('/')[-1]}"
            s3.download_file(source_bucket, source_key, local_path)

            head = s3.head_object(Bucket=source_bucket, Key=source_key)

            etag = head["ETag"].replace('"', "")
            file_size = head["ContentLength"]
            upload_time = head["LastModified"].isoformat()
            file_name = source_key.split("/")[-1]

            result = subprocess.run(
                ["clamscan", local_path],
                capture_output=True,
                text=True
            )

            if result.returncode == 0:
                scan_status = "clean"
                malware_name = "none"
                destination_bucket = CLEAN_BUCKET

            elif result.returncode == 1:
                scan_status = "infected"
                destination_bucket = QUARANTINE_BUCKET
                malware_name = "unknown"

                for line in result.stdout.splitlines():
                    if "FOUND" in line:
                        malware_name = line.split(": ", 1)[1].replace(" FOUND", "").strip()
                        break

            else:
                scan_status = "error"
                malware_name = "scan_failed"
                destination_bucket = QUARANTINE_BUCKET

            s3.upload_file(local_path, destination_bucket, source_key)

            s3.put_object_tagging(
                Bucket=destination_bucket,
                Key=source_key,
                Tagging={
                    "TagSet": [
                        {"Key": "scan-status", "Value": scan_status},
                        {"Key": "malware-name", "Value": malware_name},
                        {"Key": "scan-time", "Value": datetime.now(timezone.utc).isoformat()}
                    ]
                }
            )
            scan_time = datetime.now(timezone.utc)
            scan_time_iso = scan_time.isoformat()
            scan_time_key = scan_time.strftime("%Y%m%dT%H%M%SZ")
            safe_key = source_key.replace("/", "_")

            scan_record = {
                "file_name": file_name,
                "source_bucket": source_bucket,
                "object_key": source_key,
                "destination_bucket": destination_bucket,
                "upload_time": upload_time,
                "scan_time": datetime.now(timezone.utc).isoformat(),
                "scan_status": scan_status,
                "malware_name": malware_name,
                "etag": etag,
                "file_size": file_size,
                "processed_by": "clamav-scanner-lambda"
            }

            s3.put_object(
                Bucket=SCAN_RESULTS_BUCKET,
                Key=f"scan-results/year={scan_time.year}/month={scan_time.month:02d}/day={scan_time.day:02d}/{safe_key}_{scan_time_key}.json",
                Body=json.dumps(scan_record),
                ContentType="application/json"
            )


            s3.delete_object(Bucket=source_bucket, Key=source_key)

    return {"statusCode": 200}