spawn = require('child_process').spawn
{Subscriber, Emitter} = require 'emissary'

module.exports =
class OracleCommand
  Subscriber.includeInto(this)
  Emitter.includeInto(this)

  oracleCommand: (cmd, format, importPath) ->
    path = @getPath()
    [startOffset, endOffset] = @getPosition()

    args = ["-pos=#{path}:##{startOffset}", "-format=#{format}", cmd]
    args.push(importPath) if importPath?

    return spawn("oracle", args)

  constructor: ->
    this.on 'what-complete', (whatData) =>
      cmd = @oracleCommand(@nextCommand, "plain", whatData.what.importpath)

      stderr = ''
      cmd.stderr.on 'data', (data) =>
        stderr += data

      stdout = ''
      cmd.stdout.on 'data', (data) =>
        stdout += data

      cmd.on 'close', (code) =>
        if code
          console.log "failed to run oracle: exit status", code
          console.log stdout
          console.log stderr

        @emit "oracle-complete", @nextCommand, stdout

  what: ->
    what = @oracleCommand("what", "json")

    stderr = ''
    what.stderr.on 'data', (data) =>
      stderr += data

    stdout = ''
    what.stdout.on 'data', (data) =>
      stdout = JSON.parse(data)

    what.on 'close', (code) =>
      if code
        console.log "failed to run oracle what: exit status", code
        console.log stdout
        console.log stderr

      @emit 'what-complete', stdout

  command: (cmd) ->
    @nextCommand = cmd
    @what()

  getPath: ->
    return atom.workspaceView.getActiveView()?.getEditor()?.getPath()

  getPosition: ->
    editorView = atom.workspaceView.getActiveView()
    buffer = editorView?.getEditor()?.getBuffer()
    cursor = editorView?.getEditor()?.getCursor()

    startPosition = cursor.getBeginningOfCurrentWordBufferPosition({"includeNonWordCharacters":false})
    endPosition = cursor.getEndOfCurrentWordBufferPosition({"includeNonWordCharacters":false})

    startOffset = buffer.characterIndexForPosition(startPosition)
    endOffset = buffer.characterIndexForPosition(endPosition)

    return [startOffset, endOffset]
