# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

module.exports = (exchange) ->
  exchange.respond.client -> (error, next) ->
    depends.script-loader '/faye/client.js', ->
      next null, new Faye.Client '/faye'
