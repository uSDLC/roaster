# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
faye = require('ext/node_modules/faye')

module.exports = (url) ->
  return new faye.Client url