
# Server configs

### Scope

Every server has one set of configs that is referenced by all server processes.

Different types of servers may have different configs, depending on the purpose of that server.

Also, we'll probably have a separate set of configs for running the service locally versus running on a server. (at the time of writing, we're not doing this)

### Goals

Server configs are intended to be used for:

1) Addressing (port assignment & etc). This way, tools can use the config to find other services by name.
2) Roles & responsibilities. We can move responsibilties between different processes or servers just by changing the configs.

### Outline

{
    "services": {...}
    "apps": {...}
}

##### 'services' section

A "service" is something that's already running or available on the server, not launched by Forever. Most likely launched by Upstart or manually.

##### 'apps' section

An "app" is one Node process, launched and monitored by Forever. Each app has a unique name.

field name | description
------- | ---------
inbox | Address for nanomsg 'rep' socket, used to send commands to the app
pub | Address for nanomsg 'pub' socket, used by the app to broadcast information
express | Enables and configures an Express server
redis | Enables and configures this app's connection to Redis
taskRunner | Enables and configures this app as a task runner
