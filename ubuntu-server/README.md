# docker-ubuntu-server
Base Ubuntu server to support the docker images
"Wildsong/arcgis-server" and "Wildsong/portal-for-arcgis".

This contains a few extra packages that ArcGIS Server
and Portal for ArcGIS need, to speed up building those images.

It installs packages for python (which is now python3), pip, and uses pip to install "requests",
to make it easy to use the ArcGIS REST API.

It creates a user/group called "arcgis/arcgis" with UID/GID of 1000/1000.
The postgresql-client-12 package has been added to support ArcGIS 10.9.

$ apt list -a docker-ce 
$ VERSION_STRING=5:24.0.7-1 suport limits.conf arcgis soft nofile 65535 arcgis hard nofile 65535 arcgis soft nproc 25059 arcgis hard nproc 25059

## Build

```bash
docker build -t arcgis/ubuntu-server .
```

## Run

Just for testing... you can start an instance and use a bash shell to explore. 


```bash
docker run -it --rm arcgis/ubuntu-server bash
```

For example you should be able to run python and see this.

```bash
root@8eed5bf8768b:~# python
Python 3.8.10 (default, Jun  2 2021, 10:49:15)
[GCC 9.4.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import requests
>>> requests.__version__
'2.25.1'
>>>

$ sudo apt-get install docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin
$ sudo systemctl status docker
$ sudo usermod -aG docker ${USER}
$ su - ${USER}
$ groups

```
