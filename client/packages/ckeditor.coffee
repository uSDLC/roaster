# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
version = "4.1.2"
pkg = "full"
base = "http://download.cksource.com/CKEditor/CKEditor/CKEditor "
ckurl = "http://download.ckeditor.com"
plugin_dir = "ckeditor/plugins/"
packages =
  ckeditor: "#{base}#{version}/ckeditor_#{version}_#{pkg}.zip|."
  tableresize: "#{ckurl}/tableresize/releases/tableresize_#{version}.zip|#{plugin_dir}"
  placeholder: "#{ckurl}/placeholder/releases/placeholder_#{version}.zip|#{plugin_dir}"

toolbarGroups = [
  { name: 'document' }
  { name: 'doctools' }
  { name: 'clipboard', groups: [ 'clipboard', 'undo' ] }
  { name: 'editing', groups: [ 'find', 'selection', 'spellchecker' ] }
  { name: 'forms' }
  { name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] }
  { name: 'paragraph', groups: [ 'list', 'indent', 'blocks' ] }
  { name: 'align', groups: ['align', 'bidi'] }
  { name: 'links' }
  { name: 'insert' }
  { name: 'styles' }
  { name: 'colors' }
  { name: 'tools', groups: [ 'mode', 'tools'] }
  # { name: 'others' }
  { name: 'about' }
]
toolbarViews =
  Insert: 'document,paragraph,align,insert,links'
  Edit: 'basicstyles,styles,colors'
  Form: 'forms'
  View: 'editing,doctools,tools,others,about'
toolbarViewsOrder = "Insert,Edit,Form,View".split(',')

default_options =
  fullPage: true
  allowedContent: true
  browserContextMenuOnCtrl: true
  contentsCss: '/app.stylus'
  # scayt_autoStartup: true
  removeButtons: ''
  toolbarGroups: toolbarGroups
  toolbarViews: toolbarViews
  toolbarViewsOrder: toolbarViewsOrder
  maximize: true
  extraPlugins: 'tableresize,placeholder'
  basicEntities: false
  removePlugins: 'magicline'

editor = null

open = (id, options) ->
  options = _.extend {}, default_options, options
  options.removeButtons += ',Maximize' if options.maximize

  roaster.ckeditor.editors[id] = editor = CKEDITOR.instances.document
  _.extend editor.config, options

  editor.toolbarGroupNames = {}
  for group, index in options.toolbarGroups
    editor.toolbarGroupNames[group.name] = index
  options.toolbarViewsOrder = toolbarViewsOrder
  [toolbarViews, options.toolbarViews] = [options.toolbarViews, {}]
  options.toolbarViews[view] = list.split(',') for view,list of toolbarViews

  editor.showToolbarGroup = (name) ->
    for group in options.toolbarGroups
      index = editor.toolbarGroupNames[group.name]
      $($('.cke_toolbox span.cke_toolbar', editor.div)[index]).hide()
    for group in options.toolbarViews[name]
      index = editor.toolbarGroupNames[group]
      $($('.cke_toolbox span.cke_toolbar', editor.div)[index]).show()
    $('.cke_editor_tabs a', editor.div).removeClass 'cke_editor_tab_selected'
    $(".cke_editor_tab_#{name}", editor.div).addClass 'cke_editor_tab_selected'
    return false

  instanceReady = ->
    editor.div = $ '.cke_inner'
    tab = $ '<div class="cke_editor_tabs"></div>'
    for name in toolbarViewsOrder
      do ->
        tab_name = name
        a = $ "<a class='cke_editor_tab cke_editor_tab_#{name}'>#{name}</a>"
        a.click -> show_tab tab_name
        tab.append a
    tab.append '<span class=messages></span>'
    editor.div.prepend tab
    editor.showToolbarGroup 'Edit'
  editor.onInstanceReady = [instanceReady]
  editor.once 'instanceReady', ->
    onInstanceReady() for onInstanceReady in editor.onInstanceReady
  return editor

roaster.message = (msg) -> $('span.messages').html(msg)

last_tab = 'Edit'

show_tab = (tab_name) ->
  editor.showToolbarGroup(tab_name)
  editor.focusManager.focus()
  [last_tab, last] = [tab_name, last_tab]
  return last

read_only = (read_only = true) -> editor.setReadOnly read_only
loader = roaster.dependency(packages, '/ext/ckeditor/ckeditor.js')

toolbar = (group, tab, items...) ->
  external = (item) ->
    CKEDITOR.plugins.addExternal item, "/client/#{group}/", "#{item}.coffee"
    roaster.ckeditor.default_options.extraPlugins += ",#{item}"
  external item for item in items if item isnt '-'
  if not roaster.ckeditor.default_options.toolbarViews[tab]
    roaster.ckeditor.default_options.toolbarGroups.push name: tab
    roaster.ckeditor.default_options.toolbarViews[tab] = tab
    roaster.ckeditor.default_options.toolbarViewsOrder.push tab

module.exports = (next) ->
  roaster.ckeditor = {
    open, read_only, default_options, editors:{}, toolbar, show_tab
  }
  loader next