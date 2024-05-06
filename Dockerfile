FROM golang:1.19 as build
RUN apt-get update && apt-get install -y curl make

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -o sloop ./pkg/sloop

FROM gcr.io/distroless/base

ADD --chmod=755 --checksum=sha256:cc35059999bad461d463141132a0e81906da6c23953ccdac59629bb532c49c83 \
    https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator /aws-iam-authenticator

COPY --from=build /build/sloop /sloop
# The copy statement below can be uncommented to reflect changes to any webfiles as compared
# to the binary version of the files in use.
# COPY pkg/sloop/webserver/webfiles /webfiles
ENV PATH="/:${PATH}"
CMD ["/sloop"]
