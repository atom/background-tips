BackgroundTipsView = require '../lib/background-tips-view'
{WorkspaceView} = require 'atom'

describe "BackgroundTipsView", ->
  backgroundTips = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    backgroundTips = atom.packages.activatePackage('backgroundTips', immediate: true)

  describe "when the background-tips:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.background-tips')).not.toExist()
      atom.workspaceView.trigger 'background-tips:toggle'
      expect(atom.workspaceView.find('.background-tips')).toExist()
      atom.workspaceView.trigger 'background-tips:toggle'
      expect(atom.workspaceView.find('.background-tips')).not.toExist()
