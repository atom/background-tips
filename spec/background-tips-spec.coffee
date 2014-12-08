{$} = require 'space-pen'

BackgroundTipsView = require '../lib/background-tips-view'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "BackgroundTips", ->
  [workspaceElement, backgroundTips, backgroundTipsView] = []

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
      workspaceElement = atom.views.getView(atom.workspace)
      expect(atom.workspace.getPanes().length).toBe 1

    describe "when the pane is empty", ->
      it "attaches the view after a delay", ->
        expect(atom.workspace.getActivePane().getItems().length).toBe 0

        activatePackage ->
          expect(backgroundTipsView.parent()).not.toExist()
          advanceClock BackgroundTipsView.startDelay + 1
          expect(backgroundTipsView.parent()).toExist()

    describe "when the pane is not empty", ->
      it "does not attach the view", ->
        waitsForPromise -> atom.workspace.open()

        activatePackage ->
          advanceClock BackgroundTipsView.startDelay + 1
          expect(backgroundTipsView.parent()).not.toExist()

    describe "when a second pane is created", ->
      it "detaches the view", ->
        activatePackage ->
          advanceClock BackgroundTipsView.startDelay + 1
          expect(backgroundTipsView.parent()).toExist()

          atom.workspace.getActivePane().splitRight()
          expect(backgroundTipsView.parent()).not.toExist()

  describe "when the package is activated when there are multiple panes", ->
    beforeEach ->
      atom.workspace.getActivePane().splitRight()
      expect(atom.workspace.getPanes().length).toBe 2

    it "does not attach the view", ->
      activatePackage ->
        advanceClock BackgroundTipsView.startDelay + 1
        expect(backgroundTipsView.parent()).not.toExist()

    describe "when all but the last pane is destroyed", ->
      it "attaches the view", ->
        activatePackage ->
          atom.workspace.getActivePane().destroy()
          advanceClock BackgroundTipsView.startDelay + 1
          expect(backgroundTipsView.parent()).toExist()

          atom.workspace.getActivePane().splitRight()
          expect(backgroundTipsView.parent()).not.toExist()

          atom.workspace.getActivePane().destroy()
          expect(backgroundTipsView.parent()).toExist()

  describe "when the view is attached", ->
    beforeEach ->
      expect(atom.workspace.getPanes().length).toBe 1

      activatePackage ->
        advanceClock BackgroundTipsView.startDelay + 1

    it "has text in the message", ->
      expect(backgroundTipsView.message.text()).toBeTruthy()

    it "changes text in the message", ->
      oldText = backgroundTipsView.message.text()
      waits BackgroundTipsView.displayDuration + BackgroundTipsView.fadeDuration
      runs ->
        expect(backgroundTipsView.message.text()).not.toEqual(oldText)
