# kubernetes-cassandra

The cassandra docker image is built based on [dokcer-oracle-java-8](https://github.com/songyunlu/docker-oracle-java-8-slim) image. The Dockerfile and kubernetes manifests are created by refering to kubernetes's [cassandra statefulset tutorial](https://github.com/kubernetes/examples/tree/master/cassandra). You can get the image by `docker pull gn00023040/kubernetes-cassandra`.

The cassandra statefulset leverages the awesome modified version of [hostpath-provisioner](https://github.com/MaZderMind/hostpath-provisioner) storage calss created by @MaZderMind to store data in the host path.

Warning: the kubernetes manifesets defined here is only for development/testing purpose, do not apply them to a production environment.
