{CompositeDisposable} = require 'atom'
HistoryTracker = require './history-tracker.coffee'

module.exports = 
  historyTracker: null
  subscriptions: null

  activate: (state) ->
    @historyTracker = new HistoryTracker()
    
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    
    @subscriptions.add atom.commands.add 'atom-workspace',   
      'history-tracker:go-backwards-in-history': =>
        @historyTracker.goBackwardsInHistory()
      'history-tracker:go-forward-in-history': =>
        @historyTracker.goForwardInHistory()

  deactivate: ->
    @subscriptions.dispose()
    @historyTracker.destroy()
    @historyTracker = null
