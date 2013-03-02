# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
url = require 'url'; path = require 'path'; os = require 'os'
http = require 'http'; https = require 'https'; fs = require 'fs'
querystring = require 'querystring'; url = require 'url'
timer = require 'timer'

class Internet
  constructor: ->
    # download a file - pausing the stream while it happens
    @download = # internet.download.to(file_path).from url, => next()
      from: (@from, next) => @download_now(next); return @download
      to: (@to, next) => @download_now(next); return @download

  # Abort stream if Internet unavailable - require(internet).available(gwt)
  available: (next) ->
    head = @request('HEAD', 'http://google.com', {}, => next false)
    head.on('error', =>  next(true)).end()

  # Post known static data as either a string or url-encoded
  post: (address, data, options..., on_response) ->
    options = if options.length is 0 then {} else options[0]
    data = querystring.stringify data if typeof data isnt 'string'
    options.header ?= {}
    options.header['Content-Length'] =  data.length
    @request('POST', address, options, on_response).end data

  # prepare to post a stream of data
  post_stream: (address, options..., on_response) ->
    options = if options.length is 0 then {} else options[0]
    return @request('POST', address, options, on_response)

  # helper for http GET - returns request object
  get: (address, options..., on_response) ->
    options = if options.length is 0 then {} else options[0]
    request = @request('GET', address, options, on_response)
    request.end()
    return request
  # helper for http GET - returns request object
  get_stream: (address, options..., on_response) ->
    options = if options.length is 0 then {} else options[0]
    return request = @request('GET', address, options, on_response)
  # set how many seconds we keep retrying
  retry: (seconds) -> @retry_for = seconds; return @

  download_now: (on_download_complete) ->
    return if not on_download_complete
    console.log "Downloading //#{@from}//..."
    to = @to
    @get @from, (error, response) =>
      response.setEncoding 'binary'
      writer = fs.createWriteStream to
      response.pipe writer
      response.on 'end', =>
        console.log '...done';
        on_download_complete()
    @from = @to = ''

  request: (method, address, extra_options, on_response) ->
    address = url.parse address
    if address.protocol is 'http:'
      address.port ?= 80; transport = http
    else
      address.port ?= 443; transport = https
    options =
      method: method
      host: address.hostname
      path: address.path
      port: address.port
    options[key] = value for key, value of extra_options
    clock = timer silent:true
    request = null
    requesting = =>
      request?.abort()
      request = transport.request options, (response) =>
        on_response(null, response)
      request.on 'error', (error) =>
        if error?.code is 'ECONNREFUSED' and clock.total() < @retry_for
          return setTimeout requesting, 500
        on_response error
      return request
    return requesting()

module.exports = -> new Internet()
