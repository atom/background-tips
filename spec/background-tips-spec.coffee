{WorkspaceView, $} = require 'atom'

BackgroundTipsView = require '../lib/background-tips-view'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "BackgroundTips", ->
  [backgroundTips, backgroundTipsView] = []

  beforeEach ->
    BackgroundTipsView.displayDuration = 50
    BackgroundTipsView.fadeDuration = 1

  activatePackage = (callback) ->
    waitsForPromise ->
      atom.packages.activatePackage('background-tips').then ({mainModule}) ->
        {backgroundTipsView} = mainModule

    runs ->
      callback()

  describe "when the package is activated when there is only one pane", ->
    beforeEach ->
      atom.workspaceView = new WorkspaceView
      expect(atom.workspaceView.getPaneViews().length).toBe 1

    describe "when the pane is empty", ->
      it "attaches the view after a delay", ->
        expect(atom.workspaceView.getActivePaneViewView().getItems().length).toBe 0

        activatePackage ->
          expect(backgroundTipsView.parent()).not.toExist()
          advanceClock BackgroundTipsView.startDelay + 1
          expect(backgroundTipsView.parent()).toExist()

    describe "when the pane is not empty", ->
      it "does not attach the view", ->
        atom.workspaceView.getActivePaneView().activateItem($("item"))

        activatePackage ->
          advanceClock BackgroundTipsView.startDelay + 1
          expect(backgroundTipsView.parent()).not.toExist()

    describe "when a second pane is created", ->
      it "detaches the view", ->
        activatePackage ->
          advanceClock BackgroundTipsView.startDelay + 1
          expect(backgroundTipsView.parent()).toExist()

          atom.workspaceView.getActivePaneView().splitRight()
          expect(backgroundTipsView.parent()).not.toExist()

  describe "when the package is activated when there are multiple panes", ->
    beforeEach ->
      atom.workspaceView = new WorkspaceView
      atom.workspaceView.getActivePaneView().splitRight()
      expect(atom.workspaceView.getPaneViews().length).toBe 2

    it "does not attach the view", ->
      activatePackage ->
        advanceClock BackgroundTipsView.startDelay + 1
        expect(backgroundTipsView.parent()).not.toExist()

    describe "when all but the last pane is destroyed", ->
      it "attaches the view", ->
        activatePackage ->
          atom.workspaceView.getActivePaneView().remove()
          advanceClock BackgroundTipsView.startDelay + 1
          expect(backgroundTipsView.parent()).toExist()

  describe "when the view is attached", ->
    beforeEach ->
      atom.workspaceView = new WorkspaceView
      expect(atom.workspaceView.getPaneViews().length).toBe 1

      activatePackage ->
        advanceClock BackgroundTipsView.startDelay + 1

    it "has text in the message", ->
      expect(backgroundTipsView.message.text()).toBeTruthy()

    it "changes text in the message", ->
      oldText = backgroundTipsView.message.text()
      waits BackgroundTipsView.displayDuration + BackgroundTipsView.fadeDuration
      runs ->
        expect(backgroundTipsView.message.text()).not.toEqual(oldText)
