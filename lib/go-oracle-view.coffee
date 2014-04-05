{View} = require 'atom'
{Subscriber, Emitter} = require 'emissary'
OracleCommand = require "./oracle-command"

module.exports =
class GoOracleView extends View
  Subscriber.includeInto(this)
  Emitter.includeInto(this)

  @content: ->
    @div class: 'go-oracle tool-panel pannel panel-bottom padding', =>
      @h4 "", class: "title"
      @ul class: "oracle-data"
      @div "", class: "message"

  initialize: (serializeState) ->
    @oracle = new OracleCommand()
    @oracle.on 'oracle-complete', (command, data) =>
      @find(".title").text(" oracle - #{command}")

      for line in String(data).split("\n")
        continue if line == ""
        parts = line.split(": ")
        @find('ul').append("<li>#{parts[1]}</li>")

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
    @find('ul').empty()
    @find('.title').text(" oracle - loading")
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
