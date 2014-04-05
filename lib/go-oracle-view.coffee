{View} = require 'atom'
{Subscriber, Emitter} = require 'emissary'
OracleCommand = require "./oracle-command"

module.exports =
class GoOracleView extends View
  Subscriber.includeInto(this)
  Emitter.includeInto(this)

  @content: ->
    @div class: 'go-oracle tool-panel pannel panel-bottom padding', =>
      @div "", class: "message"

  initialize: (serializeState) ->
    @oracle = new OracleCommand()
    @oracle.on 'oracle-complete', (data) =>
      @find(".message").text(data)

    atom.workspaceView.command "go-oracle:describe", => @describe()
    atom.workspaceView.command "go-oracle:callers", => @callers()
    atom.workspaceView.command "go-oracle:callees", => @callees()
    atom.workspaceView.command "core:cancel core:close", => @destroy()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @unsubscribe
    @detach()

  showLoadingScreen: ->
    @find(".message").text("Oracle loading ...")
    atom.workspaceView.prependToBottom(this)

  describe: ->
    @showLoadingScreen()
    @oracle.command("describe")

  callers: ->
    @showLoadingScreen()
    @oracle.command("callers")

  callees: ->
    @showLoadingScreen()
    @oracle.command("callees")
