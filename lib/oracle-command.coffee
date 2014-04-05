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

      env = {"GOPATH": @goPath()}
      oracleCmd = atom.config.get('go-oracle.oraclePath')
      oracleCmd = oracleCmd.replace(/^\$GOPATH\//i, @goPath())

      console.log "What complete: #{importPath}"
      console.log "#{oracleCmd} -pos=#{path}:##{startOffset} -format=plain #{@nextCommand} #{importPath}"

      cmd = spawn(oracleCmd, ["-pos=#{path}:##{startOffset}", "-format=plain", @nextCommand, importPath], {"env": env})

      parsedData = ''
      cmd.stdout.on 'data', (data) =>
        parsedData = data #JSON.parse(data)

      cmd.on 'close', (code) =>
        @emit "oracle-complete", parsedData

  what: ->
    # Spawn the what, emit what-complete with data
    path = @getPath()
    [startOffset, endOffset] = @getPosition()

    env = {"GOPATH": @goPath()}
    oracleCmd = atom.config.get('go-oracle.oraclePath')
    oracleCmd = oracleCmd.replace(/^\$GOPATH\//i, @goPath())

    console.log "#{oracleCmd} -pos=#{path}:##{startOffset} -format=json what"

    what = spawn(oracleCmd, ["-pos=#{path}:##{startOffset}", "-format=json", "what"], {"env": env})

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

  goPath: ->
    gopath = ''
    gopathEnv = process.env.GOPATH
    gopathConfig = atom.config.get('go-oracle.goPath')
    gopath = gopathEnv if gopathEnv? and gopathEnv isnt ''
    gopath = gopathConfig if gopath is ''
    return gopath + '/'
