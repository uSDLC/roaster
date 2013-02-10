# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

# Create a HTTP server that processes requests based on the extension (being
# the characters after the final dot) - defaulting to 'html'. These drivers
# are modules in /drivers with a name that matches the extension. In
# other words, html.coffee will be loaded to process index.html. The driver
# modules return a function that is called on each HTTP request and passed
# an exchange object consisting of

#   request: a node http.ServerRequest object
#       (http://nodejs.org/api/http.html#http_class_http_serverrequest)
#   response: a node http.ServerResponse object
#       (http://nodejs.org/api/http.html#http_class_http_serverresponse)
#   cookies: a lazy cookie loader and saver
#       (https://github.com/jed/cookies)
#   environment: an object common to all http conversations on this server.
#     port: The port number this server listens on
#     debug: If true errors close server with a stack dump
#     user: Default user if no-one has logged in
#   session: an object common to a single browser conversation set
#     user: Object containing details for a guest or logged in user
#   respond: method to call to send data back to the browser - chaining support
#   faye: pubsub server-side client. Set to false for no pubsub on server
#   config: Configuration file (<config>.config.coffee)
require! 'boot/create-http-server'; require! 'boot/create-faye-server'
require! 'boot/project-init'; require! system; require! 'file-system'

# process the command line
environment = process.environment = system.command_line(
  base-dir: file-system.base ''  # convenience path to server base directory
  config: 'base'        # used to load config settings (<name>.config.coffee)
  faye: true            # true to activate pubsub - set to faye.client
  user: 'Guest'         # default user if one is not logged in
  since: new Date!.get-time!  # time of server start (epoch time)
  command-line: process.argv.join ' ' # full command line for identification
)

default-environment = ["#name=#value" for name, value of environment].sort()

# allow project to tweak settings before we commit to action
project-init.pre environment

# load an environment related config file
# command-line could have config=debug
# related file can be anywhere on the node requires paths + /config/
require("config/#{environment.config}")(environment)

# create a server ready to listen
environment.server = create-http-server environment
environment.faye = create-faye-server environment if environment.faye

# in debug mode we reload pages fresh from server.
if environment.debug
  exchange.respond.maximum-browser-cache-age = 1000

# kick-off
environment.server.listen environment.port
# lastly we do more project level initialisation
project-init.post environment

console.log """

uSDLC2 running on http://localhost:#{environment.port}

usage: go server [name=value]...
    #{default-environment.join '\n    '}

"""