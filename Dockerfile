#FROM ubuntu:16.04
FROM alpine:3.13
COPY . /tmp/build-tcl
WORKDIR /root
RUN /tmp/build-tcl/build.sh
ENTRYPOINT ["tclsh8.7"]
