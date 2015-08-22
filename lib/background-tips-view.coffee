_ = require 'underscore-plus'
{CompositeDisposable} = require 'atom'

PackageTips = {}
Tips = []

Template = """
  <ul class="centered background-message">
    <li class="message"></li>
  </ul>
"""

module.exports =
class BackgroundTipsElement extends HTMLElement
  StartDelay: 1000
  DisplayDuration: 10000
  FadeDuration: 300

  createdCallback: ->
    @index = -1
    Tips = []
    PackageTips = {}

    @disposables = new CompositeDisposable
    @disposables.add atom.workspace.onDidAddPane => @updateVisibility()
    @disposables.add atom.workspace.onDidDestroyPane => @updateVisibility()
    @disposables.add atom.workspace.onDidChangeActivePaneItem => @updateVisibility()
    @disposables.add atom.packages.onDidActivateInitialPackages =>
      for p in atom.packages.getLoadedPackages()
        @addTips p.name, p.metadata.tips if p.metadata.tips?
    @disposables.add atom.packages.onDidLoadPackage (p) =>
      @addTips p.name, p.metadata.tips if p.metadata.tips?
    @disposables.add atom.packages.onDidUnloadPackage (p) =>
      @removeTips p.name if p.metadata.tips?
    for p in atom.packages.getLoadedPackages()
      @addTips p.name, p.metadata.tips if p.metadata.tips?

    @startTimeout = setTimeout((=> @start()), @StartDelay)

  attachedCallback: ->
    @innerHTML = Template
    @message = @querySelector('.message')

  destroy: ->
    @stop()
    @disposables.dispose()
    @destroyed = true

  attach: ->
    paneView = atom.views.getView(atom.workspace.getActivePane())
    top = paneView.querySelector('.item-views')?.offsetTop ? 0
    @style.top = top + 'px'
    paneView.appendChild(this)

  detach: ->
    @remove()

  addTips: (name, tips) ->
    @removeTips name if PackageTips[name]?
    PackageTips[name] = []
    for tip in tips
      PackageTips[name].push @renderTip(tip) if tip?
    Tips = Tips.concat PackageTips[name]

  removeTips: (name) ->
    PackageTips[name] = null
    Tips = []
    for name in Object.keys(PackageTips)
      Tips = Tips.concat PackageTips[name] if PackageTips[name]?
    clearTimeout @nextTipTimeout

  getTips: ->
    Tips

  updateVisibility: ->
    if @shouldBeAttached()
      @start()
    else
      @stop()

  shouldBeAttached: ->
    atom.workspace.getPanes().length is 1 and not atom.workspace.getActivePaneItem()?

  start: ->
    return if not @shouldBeAttached() or @interval?
    @renderTips()
    @randomizeIndex()
    @attach()
    @showNextTip()
    @interval = setInterval((=> @showNextTip()), @DisplayDuration)

  stop: ->
    @remove()
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
      @message.classList.remove('fade-out')
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

module.exports = document.registerElement 'background-tips', prototype: BackgroundTipsElement.prototype
