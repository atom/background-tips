BackgroundTipsView = require './background-tips-view'

module.exports =
  activate: ->
    @backgroundTipsView = new BackgroundTipsView()

  deactivate: ->
    @backgroundTipsView.destroy()
