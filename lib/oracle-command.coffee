spawn = require('child_process').spawn
{Subscriber, Emitter} = require 'emissary'

module.exports =
class OracleCommand
  Subscriber.includeInto(this)
  Emitter.includeInto(this)

  constructor: ->
    this.on 'what-complete', (importPath) =>
      path = @getPath()
      [startOffset, endOffset] = @getPosition()

      console.log "What complete: #{importPath}"
      console.log "/Users/scott/src/gocode/bin/oracle -pos=#{path}:##{startOffset} -format=plain #{@nextCommand} #{importPath}"

      # TODO config these
      env = {"GOPATH": "/Users/scott/src/gocode"}
      cmd = spawn("/Users/scott/src/gocode/bin/oracle", ["-pos=#{path}:##{startOffset}", "-format=plain", @nextCommand, importPath], {"env": env})

      parsedData = ''
      cmd.stdout.on 'data', (data) =>
        parsedData = data #JSON.parse(data)

      cmd.on 'close', (code) =>
        @emit "oracle-complete", parsedData

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
    console.log "Launching command #{cmd}"
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
