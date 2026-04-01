# Secure File Processing & Analytics Platform on AWS

This project scans files uploaded to Amazon S3 with ClamAV, routes clean and infected files to separate buckets, stores scan results for analytics, and is being built toward Glue, Athena, and QuickSight reporting.

## Current Setup

- Bootstrap is done manually.
- Bootstrap creates the Terraform backend bucket, GitHub OIDC provider, and GitHub deployment role.
- GitHub Actions workflow will be added later for the `infra` stack only.

## ClamAV Note

- The ClamAV image refreshes virus definitions at image build time.
- Before deploying or testing the scanner, rebuild and push the latest container image so signatures stay current.
