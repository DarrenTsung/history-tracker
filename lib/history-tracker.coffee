path = require 'path'
{File, CompositeDisposable} = require 'atom'

module.exports =
class HistoryTracker
  _subscriptions: null
  _maxPathsToRemember: 1000
  _pathHistory: []
  _currentIndexInHistory: -1 
  _pathJustPopped: null
  
  constructor: -> 
    @_subscriptions = new CompositeDisposable
    @_subscriptions.add atom.workspace.onDidChangeActivePaneItem (item) => @_addToHistoryFromPaneItem(item)
    @_addToHistoryFromPaneItem atom.workspace.getActivePaneItem()
    
  dispose: ->
    @_subscriptions.dispose()
    
  goBackwardsInHistory: ->
    path = @_getBackwardPathInHistory()
    if path? 
      @_currentIndexInHistory--
      @_pathJustPopped = path
      atom.workspace.open(path)
  
  goForwardInHistory: ->
    path = @_getForwardPathInHistory()
    if path? 
      @_currentIndexInHistory++
      @_pathJustPopped = path
      atom.workspace.open(path)
      
  #region mark - INTERNAL  
  
  _addToHistoryFromPaneItem: (paneItem) ->
    @_addPath paneItem?.getPath?()
    @_removeExtraHistory()
    
  _addPath: (path) ->
    if path? and (!@_pathJustPopped? or path != @_pathJustPopped)
      @_pathHistory = @_pathHistory[0..@_currentIndexInHistory]
      @_pathHistory.push path
      @_currentIndexInHistory++
    
  _removeExtraHistory: ->
    while @_pathHistory.length > @_maxPathsToRemember
      @_pathHistory.shift()
    
  _getForwardPathInHistory: ->
    if @_currentIndexInHistory + 1 < @_pathHistory.length
      return @_pathHistory[@_currentIndexInHistory + 1]
    
  _getBackwardPathInHistory: ->
    if @_currentIndexInHistory - 1 >= 0
      return @_pathHistory[@_currentIndexInHistory - 1]
      
  #endregion
