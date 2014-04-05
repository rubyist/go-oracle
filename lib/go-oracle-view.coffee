{View} = require 'atom'

module.exports =
class GoOracleView extends View
  @content: ->
    @div class: 'go-oracle overlay from-top', =>
      @div "The GoOracle package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "go-oracle:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "GoOracleView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
