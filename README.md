# Python docker images

This is a set of tiny alpine-based images for python 2.6, 2.7, 3.4, 3.5, 3.6, 3.7, 3.8 and 3.9,
`pip` also included.

Goal is to provide base images to test python libraries locally
against multiple versions. For example:
[covador](https://github.com/baverman/covador/blob/master/ci/build.sh),
[hisser](https://github.com/baverman/hisser/blob/master/ci/build.sh),
[redis_writer](https://github.com/baverman/redis_writer/blob/master/ci/build.sh).

Dockerhub: [baverman/python26](https://hub.docker.com/r/baverman/python26/),
[baverman/python27](https://hub.docker.com/r/baverman/python27/),
[baverman/python34](https://hub.docker.com/r/baverman/python34/),
[baverman/python35](https://hub.docker.com/r/baverman/python35/),
[baverman/python36](https://hub.docker.com/r/baverman/python36/),
[baverman/python37](https://hub.docker.com/r/baverman/python37/),
[baverman/python38](https://hub.docker.com/r/baverman/python38/),
[baverman/python39](https://hub.docker.com/r/baverman/python39/).

# Building

To build images yourself:

    ./build.sh python38 [my-image-tag]
