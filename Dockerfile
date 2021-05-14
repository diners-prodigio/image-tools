FROM golang:1.14.4-alpine AS builder
WORKDIR /go/src/github.com/Portshift/klar/
COPY ./ ./
RUN CGO_ENABLED=0 go build -o klar .

FROM amazon/aws-cli:2.2.4
RUN yum install ca-certificates gettext curl wget tar git -y
RUN mkdir /licenses
COPY ./LICENSE /licenses/
RUN mkdir /app
COPY --from=builder /go/src/github.com/Portshift/klar/klar /app/
RUN chmod +x /app/klar && \
    cp /app/klar /usr/local/bin/

# install the oc client tools
RUN mkdir -p /opt/oc/
ADD https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.6/linux/oc.tar.gz /opt/oc/release.tar.gz
RUN yum update -y
RUN yum install ca-certificates gettext curl wget tar git -y \
    && yum clean all
RUN tar -xzvf  /opt/oc/release.tar.gz -C /opt/oc/ && \
    mv /opt/oc/oc /usr/local/bin/

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="klar" \
    org.label-schema.description="Simple tool to analyze images stored in a private or public Docker registry for security vulnerabilities using Clair" \
    org.label-schema.url="https://github.com/Portshift/klar" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/Portshift/klar"

### Required OpenShift Labels
ARG IMAGE_VERSION=1.0.0
LABEL name="klar" \
      vendor="Portshift" \
      version=${IMAGE_VERSION} \
      release=${IMAGE_VERSION} \
      summary="Integration of Clair and Docker Registry" \
      description="Simple tool to analyze images stored in a private or public Docker registry for security vulnerabilities using Clair"
ENTRYPOINT [""]
