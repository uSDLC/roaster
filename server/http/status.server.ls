# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

module.exports = (exchange) ->
  exchange.respond.json(
    start-time: process.environment.since
    debug-mode: process.environment.config is "debug")