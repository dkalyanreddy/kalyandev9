---
title: "New from outside Kubernetes in the Pod"
subtitle: "You need to know the 5 ways to access Pod"
#date: 2017-11-21T20: 13: 01 + 08: 00
description: "5 Ways on exposure Pod and services in kubenretes"
draft: false
tags: [ "kubernetes"]
categories: "kubernetes"
bigimg: [{src: "https://res.cloudinary.com/jimmysong/image/upload/images/20151122051.jpg", desc: "The Forbidden City Nov 22,2015"}]
---

The previous sections talked about how to access kubneretes clusters, mainly on access to this article kubenretes in the Pod and centralized way Serivce, and include the following:

- hostNetwork
- hostPort
- NodePort
- LoadBalancer
- Ingress

In fact, she said to be exposed with the exposure Pod Service is one thing, because of the Pod is the backend Service.

## hostNetwork: true

This is a direct way of the network defined Pod.

If you use `hostNetwork in the Pod: true` configured, applications running in this pod can directly see the start of the network interface pod host. All network interfaces on the host can access to the application. The following are examples of the host network defined pod of:

`` `Yaml
apiVersion: v1
kind: Pod
metadata:
  name: influxdb
spec:
  hostNetwork: true
  containers:
    - name: influxdb
      image: influxdb
`` `

Deploy the Pod:

`` `Bash
$ Kubectl create -f influxdb-hostnetwork.yml
`` `

Access to the host of the pod where the 8086 port:

`` `Bash
curl -v http: // $ POD_IP: 8086 / ping
`` `

204 No Content will see the return code of 204, indicating that a normal visit.

Note that every time you start the Pod when they are likely to be scheduled on different nodes, all external access Pod of IP is change, and the time schedule Pod also need to consider whether the port conflict on the host, so under normal circumstances unless You need to know a particular application occupies a particular port on a particular host when using `hostNetwork: true` way.

This Pod network model is that we can use a network plug and then wrapped in Pod deployed on each host, so that it can control all the Pod on the host network.

## hostPort

This is a direct way of the network defined Pod.

`HostPort` routed directly on the container port and the port node scheduled so that users can add the IP host <hostPort> Pod to access, such as the <hostIP>: <hostPort>.

`` `Yaml
apiVersion: v1
kind: Pod
metadata:
  name: influxdb
spec:
  containers:
    - name: influxdb
      image: influxdb
      ports:
        - containerPort: 8086
          hostPort: 8086
`` `

This has the disadvantage in that when the rescheduled Pod Pod is subject to change scheduled to host, so <hostIP> to change, the user must maintain a correspondence between the Pod and where the host of his own.

This way a network can be used for nginx [Ingress controller] (https://github.com/kubernetes/ingress/tree/master/controllers/nginx). 80 and 443 external traffic must go through the kubenretes node node.

## NodePort

NodePort in kubenretes there is a widely used service exposure mode. `ClusterIP` Kubernetes in default under the service of this type are used, this service will have a ClusterIP, the IP can only be accessed within the cluster, to get an external service can be accessed directly, we need to modify the service type `nodePort`.

`` `Yaml
apiVersion: v1
kind: Pod
metadata:
  name: influxdb
  labels:
    name: influxdb
spec:
  containers:
    - name: influxdb
      image: influxdb
      ports:
        - containerPort: 8086
`` `

To the service can also specify a value `nodePort`, 30000-32767 range, the value in the API server configuration file, defined by the` --service-node-port-range`.

`` `Yaml
kind: Service
apiVersion: v1
metadata:
  name: influxdb
spec:
  type: NodePort
  ports:
    - port: 8086
      nodePort: 30000
  selector:
    name: influxdb
`` `

Outside the cluster can be used kubernetes any node of IP port access to the 30,000 plus a service. kube-proxy automatically forwards the traffic to each pod of the service in round-robin fashion.

This service exposure mode, you can not let you specify a port commonly used applications they want, but you can deploy a reverse proxy as a flow inlet on the cluster.

## LoadBalancer

`LoadBalancer` can only be defined on the service. This is provided by public cloud load balancer, such as AWS, Azure, CloudStack, GCE and the like.

`` `Yaml
kind: Service
apiVersion: v1
metadata:
  name: influxdb
spec:
  type: LoadBalancer
  ports:
    - port: 8086
  selector:
    name: influxdb
`` `

View Services:

`` `Bash
$ Kubectl get svc influxdb
NAME CLUSTER-IP EXTERNAL-IP PORT (S) AGE
influxdb 10.97.121.42 10.13.242.236 8086: 30051 / TCP 39s
`` `

You can use ClusterIP internal port plus access to services such as 19.97.121.42:8086.

Outside you can access the service in two ways:

- Use any node of IP plus port 30051 to access the service
- Use `EXTERNAL-IP` to access, this is a VIP, is a cloud vendor load balancer IP, such as 10.13.242.236:8086.

## Ingress

`Ingress` resource type since the introduction of version kubernetes1.1. You must be deployed [Ingress controller] (https://github.com/kubernetes/ingress/tree/master/controllers/nginx) in order to create Ingress resources, Ingress controller is a form of plug-ins available. Ingress controller is deployed on Kubernetes of Docker containers. It's like Docker image contains a HAProxy or nginx load balancer and a controller daemon. Controller configure daemon required for reception from Kubernetes Ingress. It will generate a nginx or HAProxy configuration file, and restart the load balancer process for the changes to take effect. In other words, Ingress controller by the load balancer Kubernetes management.

Kubernetes Ingress load balancer provides typical properties: HTTP routing, sticky session, the SSL termination, through the SSL, TCP and UDP load balancing. Currently not all Ingress controller implements these features, you need to see the specific Ingress controller documentation.

`` `Yaml
apiVersion: extensions / v1beta1
kind: Ingress
metadata:
  name: influxdb
spec:
  rules:
    - host: influxdb.kube.example.com
      http:
        paths:
          - backend:
              serviceName: influxdb
              servicePort: 8086
`` `

External Access URL http://influxdb.kube.example.com/ping access the service, port 80 is the entrance, then Ingress controller directly to forward traffic to the back-end Pod, do not need to go through forwards kube-proxy, more than LoadBalancer way more efficient.

## to sum up

Overall Ingress is a very flexible and vendor support services has been more exposure, including Nginx, HAProxy, Traefik, there are a variety Service Mesh, and other services may be more suitable for exposure mode debugging services, special applications deploy.

## Reference

[Accessing Kubernetes Pods from Outside of the Cluster - alesnosek.com] (http://alesnosek.com/blog/2017/02/14/accessing-kubernetes-pods-from-outside-of-the-cluster/)
