# Setup Rails Container

Ruby on Rails in an Alpine Linux Docker container.

## SETUP

To set things up initialize **git** and build the docker image:

```
$ git init
$ git add .
$ git commit -m "initial commit"
$ make create
```

This will install Rails and set up the default, base application. You may now exit the container.

```
# exit
```

## STARTUP

Now you can restart the container but this time we can open up the required network ports and fire up the server automatically:

```
make start
```

