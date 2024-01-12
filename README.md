# firefox-esr-browsh
Fusion of jlesage/docker-firefox image and browsh-org/browsh image with the functionality of both

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

## Usage

  * [docker-firefox guide](https://github.com/jlesage/docker-firefox/blob/master/README.md)
  * [browsh guide](https://github.com/browsh-org/browsh/blob/master/README.md)

## Thanks
  * [@browsh-org](https://github.com/browsh-org) For the [Browsh](https://www.brow.sh/) in [browsh-org/browsh](https://github.com/browsh-org/browsh) ..
  * [@jlesage](https://github.com/jlesage) For the [jlesage/docker-firefox](https://github.com/jlesage/docker-firefox)
