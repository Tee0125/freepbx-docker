freepbx 15 + asterisk 16

build with instructions in link below:
* https://wiki.freepbx.org/display/FOP/Installing+FreePBX+15+on+Debian+9.6

Note: CDR / Outbound Routes module were not working well on PHP-7.2, and >=PHP-5.6 is required for FreePBX-15. However PHP version of ubuntu 14.04 was 5.5, so it does not meet requirements, and PHP version of ubuntu >=16.04 and debian >=9 were 7.2 also does not meet requirements. Fortunately PHP version of debian-8 was 5.6 which meets requirements, so I choose debian:8 as base image.

# Usage

```
docker run --net=host tee0125/freepbx
```

# Port

| port | description |
|-|-|
| 80 | http |
| 5060 | SIP (UDP) |
|10000 ~ 20000 | RTP |

# Environment Varaibles

| name | description |
|-|-|
| DBHOST | mysql db host (default: localhost) |
| DBUSER | mysql db user (default: asterisk) |
| DBPASS | mysql db pass (default: '') |
| DBNAME | mysql db name (default: asterisk) |
| CDRDBHOST | mysql cdr db host (default: $DBHOST) |
| CDRDBUSER | mysql cdr db user (default: $DBUSER) |
| CDRDBPASS | mysql cdr db pass (default: $DBPASS) |
| CDRDBNAME | mysql cdr db name (default: asteriskcdrdb) |

# Docker Image

* https://cloud.docker.com/repository/docker/tee0125/freepbx
