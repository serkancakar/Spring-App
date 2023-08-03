#!/bin/bash

iptables -A INPUT -p tcp --dport 2375 -j ACCEPT
iptables-save>/etc/systemd/scripts/ip4save
systemctl enable iptables
systemctl restart iptables

# Configuring Docker Service

sed -i 's#ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock#ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock#' /etc/systemd/system//multi-user.target.wants/docker.service

sed -i 's/chmod 666 \/var\/run\/docker.sock/chmod 777 \/var\/run\/docker.sock/'
