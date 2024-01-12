# Docker container for Firefox ESR and Browsh
[![Release](https://img.shields.io/github/release/jlesage/docker-firefox-esr.svg?logo=github&style=for-the-badge)](https://github.com/sdaxian/firefox-esr-browsh/releases/latest)
[![Docker Image Size](https://img.shields.io/docker/image-size/jlesage/firefox-esr/latest?logo=docker&style=for-the-badge)](https://hub.docker.com/r/sdaxian/firefox-esr-browsh/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/jlesage/firefox-esr?label=Pulls&logo=docker&style=for-the-badge)](https://hub.docker.com/r/sdaxian/firefox-esr-browsh)
[![Docker Stars](https://img.shields.io/docker/stars/jlesage/firefox-esr?label=Stars&logo=docker&style=for-the-badge)](https://hub.docker.com/r/sdaxian/firefox-esr-browsh)
[![Build Status](https://img.shields.io/github/actions/workflow/status/jlesage/docker-firefox-esr/build-image.yml?logo=github&branch=master&style=for-the-badge)](https://github.com/sdaxian/firefox-esr-browsh/actions/workflows/build-image.yml)
[![Source](https://img.shields.io/badge/Source-GitHub-blue?logo=github&style=for-the-badge)](https://github.com/sdaxian/firefox-esr-browsh)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg?style=for-the-badge)]()

This is a Docker container for fusion of  [Firefox ESR](https://www.mozilla.org/en-CA/firefox/enterprise/) 
and [Browsh](https://www.brow.sh/) with the functionality of both.

The GUI of the application is accessed through a modern web browser (no
installation or configuration needed on the client side) or via any VNC client.

AND

Browsh is a fully-modern text-based browser. 

---

## Quick Start

**NOTE**:
    The Docker command provided in this quick start is given as an example
    and parameters should be adjusted to your need.

Launch the container with the following command:
```shell
docker run --rm -it \
    --name firefox-esr-browsh \
    -p 5800:5800 \
    -v firefox_esr_browsh_config:/config:rw \
    sdaxian/firefox-esr-browsh
```
tty text-based browser and browse to `http://your-host-ip:5800` to access the Firefox ESR GUI. 

## More Usage and Documentation

  * [docker-firefox guide](https://github.com/jlesage/docker-firefox/blob/master/README.md)
  * [browsh guide](https://github.com/browsh-org/browsh/blob/master/README.md)

