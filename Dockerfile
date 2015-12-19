FROM phusion/baseimage:0.9.17
MAINTAINER Damien Garros <dgarros@gmail.com>

RUN     apt-get -y update && \
        apt-get -y upgrade

# dependencies
RUN     apt-get -y --force-yes install \
        git adduser libfontconfig wget ruby ruby-dev make curl \
        build-essential python-dev tcpdump

########################
### Install Fluentd  ###
########################

RUN     gem install fluentd statsd-ruby --no-ri --no-rdoc && \
        gem install dogstatsd-ruby
# RUN     fluent-gem install fluent-plugin-statsd

RUN     mkdir /etc/fluent && \
        mkdir /etc/fluent/plugin

ADD     fluentd/fluent.conf /fluent/fluent.conf
RUN     fluentd --setup ./fluent

ADD     fluentd/parser_juniper_analyticsd.rb    /etc/fluent/plugin/parser_juniper_analyticsd.rb
ADD     fluentd/out_statsd.rb                   /etc/fluent/plugin/out_statsd.rb

ADD     fluentd/fluentd.launcher.sh /etc/service/fluentd/run
RUN     chmod +x /etc/service/fluentd/run

RUN     apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


ENV HOME /root
RUN chmod -R 777 /var/log/

## Fluentd
EXPOSE 50020

CMD ["/sbin/my_init"]
