FROM python:3.11-slim

RUN useradd --uid 65532 --user-group --no-create-home srerunner

WORKDIR /opt
COPY terraform/ /opt/terraform/
COPY engine/ /opt/engine/

USER 65532:65532
ENTRYPOINT ["python3", "/opt/engine/compliance_auditor.py"]
