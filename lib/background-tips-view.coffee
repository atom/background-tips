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

  configureReactEditorTip: ->
    reactEditorTip = @renderTip('You can enable the new, faster React-based editor from the Settings View {settings-view:open}')
    @subscribe atom.config.observe 'core.useReactEditor', (useReactEditor) =>
      if useReactEditor
        _.remove(Tips, reactEditorTip)
      else
        Tips.push(reactEditorTip)

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
    @configureReactEditorTip()
    @tipsRendered = true

  renderTip: (str) ->
    str = str.replace /\{(.+)\}/g, (match, command) =>
      scopeAndCommand = command.split('>')
      [scope, command] = scopeAndCommand if scopeAndCommand.length > 1
      bindings = atom.keymap.findKeyBindings(command: command.trim())

      if scope
        for binding in bindings
          break if binding.selector == scope
      else
        binding = @getKeyBindingForCurrentPlatform(bindings)

      if binding?.keystrokes
        keystrokeLabel = _.humanizeKeystroke(binding.keystrokes).replace(/\s+/g, '&nbsp;')
        "<span class=\"keystroke\">#{keystrokeLabel}</span>"
      else
        command
    str

  getKeyBindingForCurrentPlatform: (bindings) ->
    return unless bindings?.length
    return binding for binding in bindings when binding.selector.indexOf(process.platform) != -1
    return bindings[0]
