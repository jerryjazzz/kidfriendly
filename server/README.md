
# Pre-build setup #

    npm install

Add the following to your .bashrc:

    export KFLY_DEV_MODE=1

(this flag will tell the server to use console logging)

# Building #

Single build:

    gulp build

Start watch & rebuild mode:

    gulp build watch

# Before running the server #

Get a Postgres server running locally

On OSX this can be done easily by installing: http://postgresapp.com/

# Running the server #

    cd kidfriendly/server
    node .

Note that your current working directory doesn't matter; the app will fix it.

# Running the server in auto-restart mode #

    cd kidfriendly/server
    node forever web

This mode works great when `gulp watch` is running in a seperate window. Every rebuild will
automatically trigger a server restart.
