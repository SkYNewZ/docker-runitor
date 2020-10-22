FROM --platform=$BUILDPLATFORM golang:1.15

ARG RUNITOR_VERSION
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Clone Runitor source code
WORKDIR /go/src/github.com/bdd/runitor
RUN git clone --quiet --depth=1 --branch=${RUNITOR_VERSION} https://github.com/bdd/runitor.git .

# Download dependencies
RUN go mod download

# Get final architecture
# linux/amd64, linux/arm/v7, linux/arm/v6, linux/arm64
RUN export GOOS=$(echo $TARGETPLATFORM | cut -d "/" -f1) && \
  export GOARCH=$(echo $TARGETPLATFORM | cut -d "/" -f2) && \
  echo "GOOS=$GOOS GOARCH=$GOARCH" && \
  export ARM=$(echo $TARGETPLATFORM | cut -d "/" -f3 | sed -e 's/v//') && \
  if [ ! -z "$ARM" ]; then export GOARM=$ARM && echo "GOARM=$GOARM"; fi && \
  CGO_ENABLED=0 go build \
  -ldflags="-s -w -X 'main.Version=${RUNITOR_VERSION}'" \
  -o /runitor ./cmd/runitor

FROM --platform=$BUILDPLATFORM scratch

ARG BUILD_DATE

LABEL maintainer="Quentin Lemaire <quentin@lemairepro.fr>"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=${BUILD_DATE}
LABEL org.label-schema.name="runitor"
LABEL org.label-schema.description="A command runner with healthchecks.io integration"
LABEL org.label-schema.url="https://github.com/bdd/runitor"

COPY --from=0 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=0 /runitor /runitor

USER 1000:1000
ENTRYPOINT [ "/runitor" ]
CMD [ "--help" ]
