# AWX MiniLab Environment

## Summary

AWX MiniLab is lab environment based on Vagrant, Ansible and VirtualBox. The main folder contains Vagrant code to stand up a single AWX server instance with 2 nodes (CentOS, OpenSuSE). The number of nodes and the node OS is configurable by modifying the config.yaml file. 

## Requirements

The pre-requisites are [Ansible](https://github.com/ansible/ansible), [Ansible host-manager plugin](https://github.com/devopsgroup-io/vagrant-hostmanager) , [Vagrant](https://www.vagrantup.com) and [VirtualBox](https://www.virtualbox.org), installed on the PC you intend to run it on, and 6 GB of RAM.

## Quickstart

### Installation
```
$ git clone https://github.com/mzima/awx-minilab
```

If not already present you also need to install the vagrant host-manager plugin:

```
$ vagrant plugin install vagrant-hostmanager
```

### Start
```
$ vagrant up
```

After the installation you should be able to access AWX at http://localhost:8080/. The default login is `admin/password`.

### Halt / Destroy
```
$ vagrant halt
$ vagrant destroy
```

## Configuration

The main folder contains a `config.yaml` file, which can be used to configure AWX MiniLab.

### config.yaml
```
# AWX MiniLab Configuration

# Lab settings
lab:
  domain: mini.lab
  provision: true

# AWX server settings
awx:
  cpu: 4
  memory: 4096
  hostname: awx
  port_http: 8080
  port_https: 8443

# AWX node settings
nodes:
  centos:
    count: 1
    cpu: 1
    memory: 1024
    image: centos/7
    hostname: centos
  opensuse:
    count: 1
    cpu: 1
    memory: 1024
    image: opensuse/Tumbleweed.x86_64
    hostname: opensuse
````
