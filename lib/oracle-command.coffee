spawn = require('child_process').spawn
{Subscriber, Emitter} = require 'emissary'

module.exports =
class OracleCommand
  Subscriber.includeInto(this)
  Emitter.includeInto(this)

  constructor: ->
    this.on 'what-complete', (data) =>
      console.log "What complete: #{data}"
      # run the actual command
      # emit oracle-complete
      @emit "oracle-complete", "more data"

  what: ->
    # Spawn the what, emit what-complete with data
    path = @getPath()
    [startOffset, endOffset] = @getPosition()

    console.log "/Users/scott/src/gocode/bin/oracle -pos=#{path}:##{startOffset} -format=json what"

    # TODO config these
    env = {"GOPATH": "/Users/scott/src/gocode"}
    what = spawn("/Users/scott/src/gocode/bin/oracle", ["-pos=#{path}:##{startOffset}", "-format=json", "what"], {"env": env})

    parsedData = ''
    what.stdout.on 'data', (data) =>
      parsedData = JSON.parse(data)

    what.on 'close', (code) =>
      @emit 'what-complete', parsedData.what.importpath

  command: (cmd) ->
    # set command, spawn what
    console.log "Launching command #{cmd}"
    @what()

  getPath: ->
    return atom.workspaceView.getActiveView()?.getEditor()?.getPath()

  getPosition: ->
    editorView = atom.workspaceView.getActiveView()
    buffer = editorView?.getEditor()?.getBuffer()
    cursor = editorView?.getEditor()?.getCursor()

    startPosition = cursor.getBeginningOfCurrentWordBufferPosition()
    endPosition = cursor.getEndOfCurrentWordBufferPosition()

    startOffset = buffer.characterIndexForPosition(startPosition)
    endOffset = buffer.characterIndexForPosition(endPosition)

    return [startOffset+1, endOffset] # TODO: don't +1, get period out of word regex
