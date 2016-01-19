# docker-junos-datadog
Docker container to convert Juniper Telemetry streaming data into Datadog
The contaimer is designed to work in pair with the [datadog container](https://github.com/DataDog/docker-dd-agent)

# How does it works

Juniper devices are able to stream statistics periodically to a collector.
Various format are supported : UDP/TCP, JSON or GPB

This project support
 - JSON over UDP send by QFX5100 (analyticsd)

2 Containers per device are needed to convert the Juniper format and send it to datadog
- Juniper container running Fluentd that will accept Juniper Format and convert it into Statsd
- Datadog container running the datadog agent that accept Statsd as input, this container is [provided by datadog](https://github.com/DataDog/docker-dd-agent)

This repo explain how to :
- Configure QFX5100 to stream data
- Create the Juniper container
- Configure the datadog container

## Deployment Guideline

Each Juniper device require 2 containers to send data to datadog.  
Because container are lightweight and flexible there are multiple possible deployment scenario :
 - Containers running on each Juniper device inside a [Guest VM that support Docker](https://github.com/dgarros/guestvm-coreos/wiki/Deploy-a-CoreOS-Guest-VM-on-a-QFX5100),
 - Containers for all devices deployed on a central server, each device will send data to a different port.

## Juniper Container

The Juniper container is running Fluentd with 2 specifics plugins
- **Input plugin** that accept JSON over UDP send by QFX5100 [available here](https://github.com/JNPRAutomate/fluent-plugin-juniper-telemetry)
- **Output Plugin** to send Statsd format inspired from [https://github.com/fakechris/fluent-plugin-statsd](https://github.com/fakechris/fluent-plugin-statsd)

Both containers are available on Docker cloud :
- [datadog/docker-dd-agent](https://hub.docker.com/r/datadog/docker-dd-agent/)
- [juniper/junos-dogstatsd](https://hub.docker.com/r/juniper/junos-dogstatsd/)

# Installation Guide
### How to configure Juniper devices

A configuration example is provided for QFX5100 inside [juniper_templates directory](https://github.com/JNPRAutomate/docker-junos-datadog/tree/master/juniper_templates)

**Start the Datadog Container**
```
docker run -d --name dd_qfx5100 -e API_KEY={your_api_key_here} -h "{device_hostname}"  datadog/docker-dd-agent dogstatsd
```

**Start the Juniper Container**
```
docker run --link dd_qfx5100:dogstatsd -p 51020:51020/udp -d juniper/junos-dogstatsd /sbin/my_init
```

# TODO
- Add instruction to have multiple QFX supported on the same server
- Add ansible playbook to automate deployment
