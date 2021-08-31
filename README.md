![mDNS proxy](https://raw.githubusercontent.com/hausgold/mdns-proxy/master/docs/assets/project.png)

[![Continuous Integration](https://github.com/hausgold/mdns-proxy/actions/workflows/package.yml/badge.svg?branch=master)](https://github.com/hausgold/mdns-proxy/actions/workflows/package.yml)
[![Source Code](https://img.shields.io/badge/source-on%20github-blue.svg)](https://github.com/hausgold/mdns-proxy)
[![Docker Image](https://img.shields.io/badge/image-on%20docker%20hub-blue.svg)](https://hub.docker.com/r/hausgold/mdns-proxy/)

This Docker images provides a simple proxy for tunneling requests to
mDNS-enabled Docker containers via a single endpoint. This allows bridging
regular DNS to mDNS name resolution transparently. The usage of this software
may be useful in various situations, eg. using it together with
[Dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html) on macOS (with Docker
for Mac) or as an regular entrypoint to a virtual machine or on a remote cloud
instance.

A simple example setup requires a virtual machine, some mDNS-enabled containers
running inside of it, this software running also inside of the virtual machine
and some host entry configurations.

- [Requirements](#requirements)
- [Getting starting](#getting-starting)
- [docker-compose usage example](#docker-compose-usage-example)
- [Rebind another external DNS suffix](#rebind-another-external-dns-suffix)

## Requirements

* A dedicated host where some mDNS-enabled containers are running (which will
  be made available on a single port of the host)

## Getting starting

You just need to run it like that, to get a working ruby:

```bash
$ docker run -p 80:80 --rm hausgold/mdns-proxy
```

The binded host port is then linked to the mDNS proxy which will handle
requests with various host headers (eg. test.local).

## docker-compose usage example

```yaml
ruby:
  image: hausgold/mdns-proxy
  environment:
    # The default, see "Rebind another external DNS suffix"
    - MDNS_SUFFIX='.local'
    # These root path entries will be upgraded to WebSocket
    # connections transparently. The following list is the default.
    - WEBSOCKET_PATHS='cable|sockjs-node|livereload|ws'
    # Change the maximum upload size per request
    - MAX_UPLOAD_SIZE='20m'
  ports:
    # The port to listen on for requests on the host
    - "80:80"
```

## Rebind another external DNS suffix

You can modify the incomming host names by reconfiguring the `MDNS_SUFFIX`
which defaults to `.local`. This way you can transparently rebind the host to a
different DNS name. Say you have an AWS EC2 instance with some mDNS-enabled
containers running and bind an IP to it. Setup an A DNS record for it like
`example.com` and a wildcard to the very same host.  Then you set
`MDNS_SUFFIX='.example.com'` here and your can access your mDNS containers like
this: `app.example.com`.
