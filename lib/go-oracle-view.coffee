{$, $$, View} = require 'atom-space-pen-views'
OracleCommand = require "./oracle-command"

module.exports =
class GoOracleView extends View
  @content: ->
    @div class: 'go-oracle tool-panel pannel panel-bottom padding', =>
      @h4 class: 'header', =>
        @span " oracle ", class: "title"
        @select outlet: 'modes'
      @div " Loading", class: "loading"
      @div outlet: 'data', class: 'panel-body padded'

  initialize: (serializeState) ->
    @data.on 'click', '.source', (event) =>
      # TODO probably broke as hell

      # Files usually end in: foo.go:70:31            - line 70, col 31
      # Sometemes end in a range: foo.go:84.21-84.31  - line 84, cols 21 - 31
      normal = /(.+):(\d+):(\d+)$/
      range  = /(.+):(\d+)\.(\d+)-(?:\d+)(?:\.\d+)$/

      fileURL = $(event.target).data('uri')
      matches = normal.exec(fileURL) || range.exec(fileURL)
      file = matches[1]
      line = parseInt(matches[2]) - 1
      col = parseInt(matches[3]) - 1

      newEditor = atom.workspace.open(file).then (newEditor) ->
        newEditor.setCursorBufferPosition([line, col])

    @oracle = new OracleCommand()
    @oracle.on 'oracle-complete', (command, data) =>
      @find('.loading').hide()

      @modes.empty()
      for mode in @availableModes
        @modes.append("<option value=\"#{mode}\">#{mode}</option>")
      @modes.val(command)

      @data.html $$ ->
        @ul class: 'oracle-data', =>
          # TODO get the json and use that instead of messing with text output
          for line in String(data).split("\n")
            continue if line == ""
            parts = line.split(": ")
            @li class: 'source', "data-uri": parts[0], parts[1]

    @oracle.on 'what-complete', (data) =>
      @availableModes = data.what.modes

    @modes.on 'change', =>
      # TODO maybe validate the modes since it shells out?
      @runOracle(@modes.val())

    atom.commands.add 'atom-workspace',
      'go-oracle:oracle': => @openOracle()
      'core:cancel': => @panel?.hide()
      'core:close': => @panel?.hide()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  openOracle: ->
    @panel ?= atom.workspace.addBottomPanel(item: this, visible: false, className: 'tool-panel panel-bottom')
    @panel.show()
    @runOracle('describe')

  runOracle: (command) ->
    @find('ul').empty()
    @find('.loading').show()
    @oracle.command(command)
