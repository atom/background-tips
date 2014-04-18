_ = require 'underscore-plus'
{View} = require 'atom'

Tips = require './tips'

module.exports =
class BackgroundTipsView extends View
  @startDelay: 1000
  @displayDuration: 10000
  @fadeDuration: 300

  @content: ->
    @ul class: 'background-tips centered background-message', =>
      @li outlet: 'message'

  initialize: ->
    @index = -1

    atom.workspaceView.on 'pane-container:active-pane-item-changed pane:attached pane:removed', => @updateVisibility()
    setTimeout @start, @constructor.startDelay

  attach: ->
    paneView = atom.workspaceView.getActivePaneView()
    top = paneView.children('.item-views').position()?.top ? 0
    @css('top', top)
    paneView.append(this)

  updateVisibility: ->
    if @shouldBeAttached()
      @start()
    else
      @stop()

  shouldBeAttached: ->
    atom.workspaceView.getPaneViews().length is 1 and not atom.workspace.getActivePaneItem()?

  start: =>
    return if not @shouldBeAttached() or @interval?
    @renderTips()
    @randomizeIndex()
    @message.hide()
    @attach()
    @showNextTip()
    @interval = setInterval @showNextTip, @constructor.displayDuration

  stop: =>
    @detach()
    clearInterval(@interval) if @interval?
    @interval = null

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
    str = str.replace /\{(.+)\}/g, (match, command) =>
      bindings = atom.keymap.findKeyBindings(command: command.trim())
      binding = @getKeyBindingForCurrentPlatform(bindings)
      if binding?
        "<span class=\"keystroke\">#{_.humanizeKeystroke(binding.keystrokes)}</span>"
      else
        command
    str

  getKeyBindingForCurrentPlatform: (bindings) ->
    return unless bindings?.length
    return binding for binding in bindings when binding.selector.indexOf(process.platform) != -1
    return bindings[0]
