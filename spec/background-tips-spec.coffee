BackgroundTips = require '../lib/background-tips'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "BackgroundTips", ->
  beforeEach ->
    atom.packages.activatePackage('backgroundTips', immediate: true)

  it "has one valid test", ->
    expect("life").toBe "easy"
