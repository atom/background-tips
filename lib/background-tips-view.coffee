_ = require 'underscore-plus'
{CompositeDisposable} = require 'event-kit'
Tips = require './tips'

Template = """
  <ul class="centered background-message">
    <li class="message"></li>
  </ul>
"""

module.exports =
class BackgroundTipsElement
  StartDelay: 1000
  DisplayDuration: 10000
  FadeDuration: 300

  constructor: ->
    @element = document.createElement('background-tips')
    @index = -1
    @workspaceCenter = atom.workspace.getCenter()

    @disposables = new CompositeDisposable

    @disposables.add @workspaceCenter.onDidAddPane => @updateVisibility()
    @disposables.add @workspaceCenter.onDidDestroyPane => @updateVisibility()
    @disposables.add @workspaceCenter.onDidChangeActivePaneItem => @updateVisibility()

    @startTimeout = setTimeout((=> @start()), @StartDelay)

  destroy: ->
    @stop()
    @disposables.dispose()
    @destroyed = true

  attach: ->
    @element.innerHTML = Template
    @message = @element.querySelector('.message')

    paneView = atom.views.getView(@workspaceCenter.getActivePane())
    top = paneView.querySelector('.item-views')?.offsetTop ? 0
    @element.style.top = top + 'px'
    paneView.appendChild(@element)

  detach: ->
    @element.remove()

  updateVisibility: ->
    if @shouldBeAttached()
      @start()
    else
      @stop()

  shouldBeAttached: ->
    @workspaceCenter.getPanes().length is 1 and not @workspaceCenter.getActivePaneItem()?

  start: ->
    return if not @shouldBeAttached() or @interval?
    @renderTips()
    @randomizeIndex()
    @attach()
    @showNextTip()
    @interval = setInterval((=> @showNextTip()), @DisplayDuration)

  stop: ->
    @element.remove()
    clearInterval(@interval) if @interval?
    clearTimeout(@startTimeout)
    clearTimeout(@nextTipTimeout)
    @interval = null

  randomizeIndex: ->
    len = Tips.length
    @index = Math.round(Math.random() * len) % len

  showNextTip: ->
    @index = ++@index % Tips.length
    @message.classList.remove('fade-in')
    @nextTipTimeout = setTimeout =>
      @message.innerHTML = Tips[@index]
      @message.classList.add('fade-in')
    , @FadeDuration

  renderTips: ->
    return if @tipsRendered
    for tip, i in Tips
      Tips[i] = @renderTip(tip)
    @tipsRendered = true

  renderTip: (str) ->
    str = str.replace /\{(.+)\}/g, (match, command) =>
      scopeAndCommand = command.split('>')
      [scope, command] = scopeAndCommand if scopeAndCommand.length > 1
      bindings = atom.keymaps.findKeyBindings(command: command.trim())

      if scope
        for binding in bindings
          break if binding.selector is scope
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
    return binding for binding in bindings when binding.selector.indexOf(process.platform) isnt -1
    return bindings[0]
