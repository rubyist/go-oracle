{View} = require 'atom'
{Subscriber, Emitter} = require 'emissary'
OracleCommand = require "./oracle-command"

module.exports =
class GoOracleView extends View
  Subscriber.includeInto(this)
  Emitter.includeInto(this)

  @content: ->
    @div class: 'go-oracle tool-panel panel-bottom padding', =>
      @div "", class: "message"

  initialize: (serializeState) ->
    @oracle = new OracleCommand()
    @oracle.on 'oracle-complete', (data) =>
      @find(".message").text(data)

      atom.workspaceView.prependToBottom(this)

    atom.workspaceView.command "go-oracle:describe", => @describe()
    atom.workspaceView.command "go-oracle:callers", => @callers()
    atom.workspaceView.command "go-oracle:callees", => @callees()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @unsubscribe
    @detach()

  describe: ->
    @oracle.command("describe")

    # this.find('.message').text("Describe")
    # if @hasParent()
    #   @detach()
    # else
    #   atom.workspaceView.append(this)

  callers: ->
    @oracle.command("callers")
    # console.log "Go Oracle: Callers"
    # this.find('.message').text("Callers")
    # if @hasParent()
    #   @detach()
    # else
    #   atom.workspaceView.append(this)

  callees: ->
    console.log "Go Oracle: Callees"
    this.find('.message').text("Callees")
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
