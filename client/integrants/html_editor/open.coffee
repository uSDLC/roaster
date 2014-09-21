# Copyright (C) 2014 paul@marrington.net, see /GPL for license
requires = (ready) ->
  require.packages 'ckeditor4', => require 'dom', ready
  
default_options =
  height: "auto"
  fullPage: false
  autoGrow_onStartup: true
  resize_enabled: false
  magicline_putEverywhere: true
  allowedContent: true
  browserContextMenuOnCtrl: true
  scayt_autoStartup: false
  removeButtons: ''
  extraPlugins: 'tableresize,placeholder,widget,lineutils,find,'+
    'codeTag,ckeditor-gwf-plugin,leaflet,div,pagebreak,'+
    'codesnippet'

class Open  
  editor: (@host, ready) -> requires (imports) =>
    CKEDITOR.config.font_names += ';GoogleWebFonts'
    he = @host.walk('html_editor/..')
    opts = [he.integrant.options]
    options = {}; opts.unshift default_options
    options[k] ?= v for k,v of o for o in opts
    @cke = CKEDITOR.replace @host.container, options
    he.ckeditor = @cke
    @cke.on 'instanceReady', =>
      @host.integrant.toolbar.prepare(@cke)
      @host.integrant.file.prepare(@cke)
      do adjust_height = =>
        @cke.container.hide()
        process.nextTick =>
          height = @host.clientHeight
          @cke.container.show()
          @cke.resize '100%', height
        imports.dom.resize_event adjust_height
      @host.walk('tabs/Font').select()
      @cke.focus()
      ready()

module.exports = Open