{_, View} = require 'atom'

Tips = require './tips'

module.exports =
class BackgroundTipsView extends View
  @startDelay: 1000
  @displayDuration: 6000
  @fadeDuration: 300

  @content: ->
    @ul class: 'background-tips centered background-message', =>
      @li outlet: 'message'

  initialize: ->
    @index = -1

    atom.workspaceView.on 'pane-container:active-pane-item-changed', @onActiveItemChanged
    setTimeout @start, @constructor.startDelay

  attach: ->
    atom.workspaceView.vertical.append(this)

  onActiveItemChanged: =>
    if @getActiveItem()
      @stop()
    else
      @start()

  getActiveItem: ->
    atom.workspaceView.getActivePaneItem()

  start: =>
    return if @getActiveItem() or @interval
    @renderTips()
    @randomizeIndex()
    @message.hide()
    @attach()
    @showNextTip()
    @interval = setInterval @showNextTip, @constructor.displayDuration

  stop: =>
    @detach()
    clearInterval(@interval) if @interval?

  randomizeIndex: ->
    len = Tips.length
    @index = Math.round(Math.random() * len) % len

  showNextTip: =>
    @index = ++@index % Tips.length
    @message.fadeOut @constructor.fadeDuration, =>
      @message.html(Tips[@index])
      @message.fadeIn(@constructor.fadeDuration)

  renderTips: ->
    return if @tipsRendered
    for tip, i in Tips
      Tips[i] = @renderTip(tip)
    @tipsRendered = true

  renderTip: (str) ->
    str = str.replace /\{(.+)\}/g, (match, command) ->
      bindings = atom.keymap.keyBindingsForCommand(command.trim())
      if bindings?.length
        "<span class=\"keystroke\">#{_.humanizeKeystroke(bindings[0].keystroke)}</span>"
      else
        command
    str
