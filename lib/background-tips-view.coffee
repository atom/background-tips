{_, View} = require 'atom'

module.exports =
class BackgroundTipsView extends View
  @content: ->
    @ul class: 'background-tips centered background-message', =>
      @li outlet: 'message'

  initialize: ->
    @index = -1
    @attach()
    setTimeout @start, 1000

  attach: ->
    atom.workspaceView.vertical.append(this)


  start: =>
    @renderTips()
    @showNextTip()
    setInterval @showNextTip, 5000

  showNextTip: =>
    tips = @constructor.tips
    @index = ++@index % tips.length
    @message.fadeOut 200, =>
      @message.html(tips[@index])
      @message.fadeIn(200)

  renderTips: ->
    for tip, i in @constructor.tips
      @constructor.tips[i] = @renderTip(tip)

  renderTip: (str) ->
    str = str.replace /\{(.+)\}/g, (match, command) ->
      bindings = atom.keymap.keyBindingsForCommand(command.trim())
      if bindings?.length
        "<span class=\"keystroke\">#{_.humanizeKeystroke(bindings[0].keystroke)}</span>"
      else
        command
    str


  @tips: [
    'Everything Atom can do is in the Command Palette. See it by using {command-palette:toggle}',
    'Toggle the Tree View with {tree-view:toggle}'
  ]
