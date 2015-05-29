GoOracleView = require './go-oracle-view'

module.exports =
  config:
    goPath:
      type: 'string'
      default: ''
    oraclePath:
      type: 'string'
      default: '$GOPATH/bin/oracle'

  goOracleView: null

  activate: (state) ->
    @goOracleView = new GoOracleView(state.goOracleViewState)

  deactivate: ->
    @goOracleView.destroy()

  serialize: ->
    goOracleViewState: @goOracleView.serialize()
