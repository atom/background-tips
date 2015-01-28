module.exports =
  activate: ->
    BackgroundTipsView = require './background-tips-view'
    @backgroundTipsView = new BackgroundTipsView()

  deactivate: ->
    @backgroundTipsView.destroy()
