# Set up

FROM alpine:latest as build
WORKDIR /code
RUN apk add --update --no-cache --quiet wget gcc libc-dev automake autoconf \
    g++ pcre-dev zlib-dev make
RUN wget -q -O e2g.tar.gz https://github.com/e2guardian/e2guardian/archive/5.3.3.tar.gz
RUN tar xfz e2g.tar.gz
RUN cd /code/e2guardian-5.3.3/ && \ 
    ./autogen.sh && \
    ./configure --disable-dependency-tracking --quiet && \ 
    make -s && \ 
    make -s install

FROM alpine:latest as prod
COPY --from=build /usr/local /opt
RUN apk add --update --no-cache --quiet libgcc libstdc++ pcre openssl \
    shadow tzdata

