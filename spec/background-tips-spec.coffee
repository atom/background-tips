{WorkspaceView} = require 'atom'

BackgroundTips = require '../lib/background-tips'
BackgroundTipsView = require '../lib/background-tips-view'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "BackgroundTips", ->
  [backgroundTips, backgroundTipsView] = []
  beforeEach ->
    atom.workspaceView = new WorkspaceView()

    BackgroundTipsView.displayDuration = 50
    BackgroundTipsView.fadeDuration = 1

    backgroundTips = atom.packages.activatePackage('background-tips', immediate: true)
    backgroundTipsView = backgroundTips.mainModule.backgroundTipsView

  it "creates the view", ->
    expect(backgroundTipsView).toBeDefined()

  describe "when there are no buffers open", ->
    it "attaches after a delay", ->
      expect(backgroundTipsView.parent()).not.toExist()
      advanceClock BackgroundTipsView.startDelay + 1
      expect(backgroundTipsView.parent()).toExist()

    describe "when the tips are attached", ->
      beforeEach ->
        advanceClock BackgroundTipsView.startDelay + 1

      it "has text in the message", ->
        expect(backgroundTipsView.message.text()).toBeTruthy()

      it "changes text in the message", ->
        oldText = backgroundTipsView.message.text()

        waits BackgroundTipsView.displayDuration + BackgroundTipsView.fadeDuration

        runs ->
          expect(backgroundTipsView.message.text()).not.toEqual(oldText)

  describe "when there is a buffer open", ->
    beforeEach ->
      atom.workspaceView.openSync()
      atom.workspaceView.attachToDom()

    it "does not attach after a delay", ->
      expect(backgroundTipsView.parent()).not.toExist()
      advanceClock BackgroundTipsView.startDelay + 1
      expect(backgroundTipsView.parent()).not.toExist()

    it "attaches when the buffer is closed", ->
      advanceClock BackgroundTipsView.startDelay + 1
      expect(backgroundTipsView.parent()).not.toExist()
      atom.workspaceView.getActivePane().destroyItem(atom.workspaceView.getActivePaneItem())
      expect(backgroundTipsView.parent()).toExist()

  describe "when a buffer opens after starting", ->
    beforeEach ->
      atom.workspaceView.attachToDom()
      advanceClock BackgroundTipsView.startDelay + 1

    it "detaches the background tips", ->
      expect(backgroundTipsView.parent()).toExist()
      atom.workspaceView.openSync()
      expect(backgroundTipsView.parent()).not.toExist()
