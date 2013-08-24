# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
Internet = require 'internet'; path = require 'path'
dirs = require 'dirs'; fs = require 'fs'
steps = require 'steps'; files = require 'files'

module.exports = (exchange) ->
  results = {}

  download = (key, url, next) ->
    file = path.basename url
    file = "#{key}.#{file}" if file.indexOf(key) is -1
    file = dirs.base 'ext', file
    downloader = new Internet().download
    
    has_been_done_before = ->
      @long_operation()
      fs.exists file, @next (exists) ->
        if exists then @abort(); next(null)
        
    download_file = -> downloader.from(url).to file, @next
      
    return_result = -> next(file)
    
    steps(
      has_been_done_before
      download_file
      return_result
    )

  process_zip = (file, to, rename, next) ->
    base = dirs.base 'ext', to
    steps(
      ->  @requires 'adm-zip'
      ->  new @adm_zip(file).extractAllTo base, true
      ->  fs.readdir base, @next (@error, @files) ->
      ->  @files = @files.filter (file) -> file[0] isnt '.'
      ->  @skip() if @files.length isnt 1 or not rename
      ->  fs.rename path.join(base,@files[0]), path.join(base, rename), @next
      ->  next()
    )

  process_file = (file, to, rename, next) ->
    name_to_use = dirs.base 'ext', "#{to}#{path.extname(file)}"
    steps(
      ->  dirs.mkdirs path.dirname(name_to_use), @next
      ->  files.copy file, name_to_use, @next
      ->  @skip() if not rename
      ->  fs.rename rename.split('=')..., @next
      ->  next()
    )

  load = (key, url, next) ->
    [url, to, rename] = url.split '|'; to ?= key
    download key, url, (file) ->
      return next() if not file
      results[key] = true
      if path.extname(url) is '.zip' or url.indexOf('/zip/') isnt -1
        process_zip file, to, rename, next
      else
        process_file file, to, rename, next
        
  load_from_urls = ->
    @long_operation()
    for key, url of exchange.request.url.query
      @call -> load key, url, @parallel()
      
  return_results = -> exchange.respond.json results
      
  steps(
    load_from_urls
    return_results
  )
