ARG IMAGE_BASE="golang"
ARG IMAGE_TAG="1.12.7-alpine"
FROM ${IMAGE_BASE}:${IMAGE_TAG} AS builder

ENV GOPATH=/go

ENV SOURCE=github.com/abiosoft/parent
ENV SOURCE_ROOT=${GOPATH}/src/${SOURCE}
ENV SOURCE_TAG="master"

WORKDIR /go/src

RUN sed -i -e 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories && \
    apk --update add --no-cache --virtual dependency git && \
    go get -d -u ${SOURCE} && \
    git -C "$(go env GOPATH)"/src/${SOURCE} reset --hard "${SOURCE_TAG}" && \
    cd ${SOURCE_ROOT} && \
    go get -v && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o ${GOPATH}/bin/parent . && \
    apk del dependency

FROM alpine:3.10.1
COPY --from=builder /go/bin/parent /usr/bin/parent

ENV MY_ENV=value

ENTRYPOINT ["/usr/bin/parent"]
CMD ["echo", "$MY_ENV"]
