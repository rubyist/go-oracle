GoOracleView = require './go-oracle-view'

module.exports =
  goOracleView: null

  activate: (state) ->
    @goOracleView = new GoOracleView(state.goOracleViewState)

  deactivate: ->
    @goOracleView.destroy()

  serialize: ->
    goOracleViewState: @goOracleView.serialize()
