FROM registry.access.redhat.com/ubi9-minimal:latest

ENV VENV=/insights-content-template-renderer-venv \
    HOME=/insights-content-template-renderer

RUN microdnf install --nodocs --noplugins -y python3.11

WORKDIR $HOME

COPY . $HOME

ENV PATH="$VENV/bin:$PATH"

RUN python3.11 -m venv $VENV
RUN pip install --verbose --no-cache-dir -U pip setuptools wheel
RUN pip install --verbose --no-cache-dir -r requirements.txt

# Clean up not necessary packages if useful
RUN pip uninstall -y py #https://pypi.org/project/py/

RUN microdnf clean all
RUN rpm -e --nodeps sqlite-libs krb5-libs libxml2 readline

USER 1001

EXPOSE 8000

LABEL \
    io.k8s.description=insights-content-template-renderer \
    io.k8s.description=insights-content-template-renderer \
    io.openshift.tags="" \
    summary=insights-content-template-renderer

CMD ["uvicorn", "insights_content_template_renderer.endpoints:app", "--host=0.0.0.0", "--port=8000", "--log-config", "logging.yml"]
