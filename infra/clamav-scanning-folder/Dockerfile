FROM public.ecr.aws/lambda/python:3.12

RUN dnf install -y \
    clamav \
    clamav-update \
    tar gzip && \
    freshclam || true

COPY clamav_scanner.py ${LAMBDA_TASK_ROOT}

CMD ["clamav_scanner.lambda_handler"]