BackgroundTipsView = require './background-tips-view'

module.exports =
  backgroundTipsView: null

  activate: (state) ->
    @backgroundTipsView = new BackgroundTipsView(state.backgroundTipsViewState)

  deactivate: ->
    @backgroundTipsView.detach()
