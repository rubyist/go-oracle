GoOracleView = require './go-oracle-view'

module.exports =
  configDefaults:
    goPath: ""
    oraclePath: "$GOPATH/bin/oracle"

  goOracleView: null

  activate: (state) ->
    @goOracleView = new GoOracleView(state.goOracleViewState)

  deactivate: ->
    @goOracleView.destroy()

  serialize: ->
    goOracleViewState: @goOracleView.serialize()
