# Copyright (C) 2013 paul@marrington.net, see GPL for license
Writable = require('stream').Writable
fs = require 'fs'; require 'common/strings'

specials = {'script', 'style', 'textarea'}

class Sax extends Writable 
  constructor: ->
    super()
    @partial = ''
    @in_special = null
    @on 'finish', ->
      @emit('text', @partial) if @partial.length
    
  _write: (data, encoding, next) ->
    data = @partial + data.toString()
    start = 0
    while (tag_start = data.indexOf('<', start)) != -1
      if not @in_special
        @emit 'text', data[start..tag_start - 1] if start isnt tag_start
        start = tag_start + 1
        break if (tag_end = data.indexOf('>', tag_start)) is -1
        event = 'opening_tag'
        if (is_close = data[start]) is '/' then start++; event = 'closing_tag'
        end -= 1 if data[end = tag_end - 1] is '/'
        # known weakness - spaces in quoted values will be separate parts
        parts = data[start..end].split /\s+/g
        if specials[tag = parts[0].toLowerCase()]
          @in_special = new RegExp "<\s*/\s*#{tag}\s*>"
        @emit event, parts...
        start = tag_end + 1
      else if (tag_start = data.regex_index_of(@in_special, tag_start)) isnt -1
        @in_special = null
        @emit 'text', data[start..tag_start - 1]
        start = data.indexOf('>', tag_start) + 1
        @emit 'closing_tag', data[tag_start + 2..start - 2]
      else # end of chunk
        @emit 'text', data[start..] if start < data.length
        start = data.length
        break
    @partial = data[start..]
    next()

module.exports = Sax
