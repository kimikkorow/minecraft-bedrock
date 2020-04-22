##################  for dev  #########################
FROM alpine:latest as builder

# config server
ENV SERVER_HOME="/mcpe" \
  SERVER_PATH="/mcpe/server" \
  SCRIPT_PATH="/mcpe/script" \
  DEFAULT_CONFIG_PATH="/mcpe/default-config" \
  DATA_PATH="/data"
ENV CORE_VERSION="1.14.60.5" \
  IMAGE_VERSION="1"
# unzip pack
RUN apk --no-cache add unzip wget && \
  mkdir -p $SERVER_PATH && \
  mkdir -p $DEFAULT_CONFIG_PATH && \
  wget -nv https://minecraft.azureedge.net/bin-linux/bedrock-server-$CORE_VERSION.zip -O /tmp/bedrock.zip
RUN unzip -q /tmp/bedrock.zip -d $SERVER_PATH && \
  mv $SERVER_PATH/permissions.json $DEFAULT_CONFIG_PATH/ && \
  mv $SERVER_PATH/server.properties $DEFAULT_CONFIG_PATH/ && \
  mv $SERVER_PATH/whitelist.json $DEFAULT_CONFIG_PATH/ && \
  rm $SERVER_PATH/bedrock_server_realms.debug && \
  rm /tmp/bedrock.zip

# COPY ./profile/mcpe $DEFAULT_CONFIG_PATH
COPY ./script $SCRIPT_PATH


##################  for relaese  #########################
# FROM ubuntu:18.04 as production
FROM debian:10-slim as production

# install packages & config docker
RUN apt-get update && \
 apt-get -y install libcurl4 && \
 apt-get -y autoremove && \
 apt-get clean

# config server
ENV LD_LIBRARY_PATH .
ENV SERVER_HOME="/mcpe" \
  SERVER_PATH="/mcpe/server" \
  SCRIPT_PATH="/mcpe/script" \
  DEFAULT_CONFIG_PATH="/mcpe/default-config" \
  DATA_PATH="/data"

COPY --from=builder $SERVER_HOME $SERVER_HOME

RUN ln -sf $DATA_PATH/permissions.json $SERVER_PATH/permissions.json \
  ln -sf $DATA_PATH/whitelist.json $SERVER_PATH/whitelist.json \
  ln -sf $DATA_PATH/server.properties $SERVER_PATH/server.properties \
  ln -sf $DATA_PATH/worlds $SERVER_PATH

WORKDIR ${SERVER_PATH}
EXPOSE 19132/udp

# RUN
CMD ["/mcpe/script/start.sh"]
