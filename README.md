# eternal-terminal
[![Build Status](https://img.shields.io/travis/demyxco/eternal-terminal?style=flat)](https://travis-ci.org/demyxco/eternal-terminal)
[![Docker Pulls](https://img.shields.io/docker/pulls/demyx/eternal-terminal?style=flat&color=blue)](https://hub.docker.com/r/demyx/eternal-terminal)
[![Architecture](https://img.shields.io/badge/linux-amd64/arm64-important?style=flat&color=blue)](https://hub.docker.com/r/demyx/eternal-terminal)
[![Alpine](https://img.shields.io/badge/alpine-3.12.3-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/eternal-terminal)
[![OpenSSH](https://img.shields.io/badge/openssh-8.3p1-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/eternal-terminal)
[![eternal-erminal](https://img.shields.io/badge/et-6.0.13-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/eternal-terminal)
[![Buy Me A Coffee](https://img.shields.io/badge/buy_me_coffee-$5-informational?style=flat&color=blue)](https://www.buymeacoffee.com/VXqkQK5tb)
[![Become a Patron!](https://img.shields.io/badge/become%20a%20patron-$5-informational?style=flat&color=blue)](https://www.patreon.com/bePatron?u=23406156)

Eternal Terminal (ET) is a remote shell that automatically reconnects without interrupting the session. Learn how to install and use it here https://eternalterminal.dev.

### Inspirations
ET was heavily inspired by several other projects:
* ssh: Ssh is a great remote terminal program, and in fact ET uses ssh to initialize the connection. The big difference between ET and ssh is that an ET session can survive network outages and IP roaming. With ssh, one must kill the ssh session and reconnect after a network outage.
* autossh: Autossh is a utility that automatically restarts an ssh session when it detects a reconnect. It's a more advanced version of doing "while true; ssh myhost.com". Although autossh will automatically reconnect, it will start a new session each time. This means, if we use tmux with control mode, we must wait for the ssh connection to die and then re-attach. ET saves valuable time by maintaining your tmux session even when the TCP connection dies and resuming quickly.
* mosh: Mosh is a popular alternative to ET. While mosh provides the same core funtionality as ET, it does not support native scrolling nor tmux control mode (tmux -CC).

TITLE | DESCRIPTION
--- | ---
SSH PORT | 22
ET PORT | 2022

## Updates & Support
[![Code Size](https://img.shields.io/github/languages/code-size/demyxco/eternal-terminal?style=flat&color=blue)](https://github.com/demyxco/eternal-terminal)
[![Repository Size](https://img.shields.io/github/repo-size/demyxco/eternal-terminal?style=flat&color=blue)](https://github.com/demyxco/eternal-terminal)
[![Watches](https://img.shields.io/github/watchers/demyxco/eternal-terminal?style=flat&color=blue)](https://github.com/demyxco/eternal-terminal)
[![Stars](https://img.shields.io/github/stars/demyxco/eternal-terminal?style=flat&color=blue)](https://github.com/demyxco/eternal-terminal)
[![Forks](https://img.shields.io/github/forks/demyxco/eternal-terminal?style=flat&color=blue)](https://github.com/demyxco/eternal-terminal)

* Auto built weekly on Saturdays (America/Los_Angeles)
* Rolling release updates
* For support: [#demyx](https://webchat.freenode.net/?channel=#demyx)

## Usage
REMOTE MACHINE: Run eternal terminal server first
```
docker run -dit \
--name demyx_et \
-v demyx_ssh:/home/demyx/.ssh \
-p 2222:22 \
-p 2022:2022 \
demyx/eternal-terminal
```

REMOTE MACHINE: Copy authorized_keys to volume
```
docker cp /home/"$USER"/.ssh/authorized_keys demyx_et:/home/demyx/.ssh
```

REMOTE MACHINE: Verify authorized_keys is in the volume
```
docker exec -t demyx_et ls -al /home/demyx/.ssh
```

REMOTE MACHINE: Restart container so permissions are set
```
docker restart demyx_et
```

LOCAL MACHINE: Make ssh alias (~/.ssh/config)
```
Host example
     HostName example.com
     User demyx
     Port 2222
```

LOCAL MACHINE: Run et command using alias (assuming et is installed on local machine)
```
et example
```
