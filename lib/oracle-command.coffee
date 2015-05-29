spawn = require('child_process').spawn
{Emitter} = require 'emissary'

module.exports =
class OracleCommand
  Emitter.includeInto(this)

  oracleCommand: (cmd, format, importPath) ->
    path = @getPath()
    [startOffset, endOffset] = @getPosition()

    gopath = @goPath()
    env = {"GOPATH": gopath}
    oracleCmd = atom.config.get('go-oracle.oraclePath')
    oracleCmd = oracleCmd.replace(/^\$GOPATH\//i, gopath)

    args = ["-pos=#{path}:##{startOffset}", "-format=#{format}", cmd]
    args.push(importPath) if importPath?

    console.log "#{oracleCmd} -pos=#{path}:##{startOffset} -format=plain #{cmd} #{importPath}"

    return spawn(oracleCmd, args, {"env": env})

  constructor: ->
    this.on 'what-complete', (whatData) =>
      cmd = @oracleCommand(@nextCommand, "plain", whatData.what.importpath)
      parsedData = ''
      cmd.stdout.on 'data', (data) =>
        parsedData = data
      cmd.stderr.on 'data', (data) =>
        console.error "Error running \""+@nextCommand + "\": " + data
      cmd.on 'close', (code) =>
        @emit "oracle-complete", @nextCommand, parsedData

  what: ->
    what = @oracleCommand("what", "json")
    parsedData = ''
    what.stdout.on 'data', (data) =>
      parsedData = JSON.parse(data)
    what.stderr.on 'data', (data) =>
      console.error "Error running \"what\": " + data
    what.on 'close', (code) =>
      @emit 'what-complete', parsedData

  command: (cmd) ->
    @nextCommand = cmd
    @what()

  getPath: ->
    atom.workspace.getActiveTextEditor()?.getPath()

  getPosition: ->
    editor = atom.workspace.getActiveTextEditor()
    buffer = editor?.getBuffer()
    cursor = editor?.getLastCursor()

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
