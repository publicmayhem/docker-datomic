FROM clojure:openjdk-11-slim-buster

# Taken from pointslope/docker-datomic-pro with updates
MAINTAINER Rob Law "robert.law@egiraffe.co.uk"

ENV DATOMIC_VERSION 1.0.6165
ENV DATOMIC_HOME /opt/datomic-pro
ENV DATOMIC_DATA $DATOMIC_HOME/data

RUN \
apt-get update && \
apt-get install -y unzip curl

# Datomic Pro Starter as easy as 1-2-3
# 1. Create a .credentials file containing user:pass
# for downloading from my.datomic.com
ONBUILD ADD .credentials /tmp/.credentials

# 2. Make sure to have a config/ folder in the same folder as your
# Dockerfile containing the transactor property file you wish to use
ONBUILD RUN curl -u $(cat /tmp/.credentials) -SL https://my.datomic.com/repo/com/datomic/datomic-pro/$DATOMIC_VERSION/datomic-pro-$DATOMIC_VERSION.zip -o /tmp/datomic.zip \
  && unzip /tmp/datomic.zip -d /tmp \
  && rm -f /tmp/datomic.zip

ONBUILD RUN mv /tmp/datomic-pro-$DATOMIC_VERSION/* /opt/datomic-pro/

ONBUILD ADD config $DATOMIC_HOME/config

WORKDIR $DATOMIC_HOME
ENTRYPOINT ["./bin/transactor"]

# 3. Provide a CMD argument with the relative path to the
# transactor.properties file it will supplement the ENTRYPOINT
VOLUME $DATOMIC_DATA

EXPOSE 4334 4335 4336
