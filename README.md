# YASD

**Y**et **A**nother **S**ervice **D**iscovery

## What is YASD?

YASD is a simple service discovery mainly for connecting Erlang nodes. YASD only registers nodes of a service in-memory and does not need any persistent storage as nodes should constantly inform YASD about their health.

YASD also supports tags on nodes so nodes with specific tags can be queried.

The datastore is a simple GenServer.

## API

### Register node [PUT /api/v1/service/{service_name}/register?ip={ip}]

You can register your nodes by calling this method. Note that the `service_name` and `ip` params
are mandatory.

If successful this method returns a `HTTP 204` status code without any content.

### List service nodes [GET /api/v1/service/{service_name}/nodes]

You can list registered nodes in a service by calling this method.

 + Response (application/json)

   ["192.168.1.1", "192.168.1.2"] 

### List all services [GET /api/v1/services]

You can list all registered services by calling this method. Note that even services with 0 nodes
will be returned.

 + Response (application/json)

   ["service1", "service2"]

## Running

Primarily you should use YASD docker image to run YASD in environment of your choice.

```
# This will run YASD on port 4001
docker run -d -p4001:4001 alisinabh/yasd
```

### Environment variables

 - `PORT`: Port to run YASD web server on. (default: 4001)
 - `JANITOR_SWEEP_INTERVAL`: Amount of time to run janitor on services in seconds. (default: 30)
 - `HEARTBEAT_TIMEOUT`: Amount of time which a node is considered dead afterwards in seconds. (default: 90)
