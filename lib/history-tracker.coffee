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
    [path, index] = @_getBackwardPathInHistory()
    if path?
      @_currentIndexInHistory = index
      @_pathJustPopped = path
      atom.workspace.open(path)

  goForwardInHistory: ->
    [path, index] = @_getForwardPathInHistory()
    if path?
      @_currentIndexInHistory = index
      @_pathJustPopped = path
      atom.workspace.open(path)


  # pragma mark - Internal
  _addToHistoryFromPaneItem: (paneItem) ->
    @_addPathFromPane paneItem
    @_removeExtraHistory()

  _addPathFromPane: (paneItem) ->
    path = paneItem?.getPath?()
    if path? and (!@_pathJustPopped? or path != @_pathJustPopped)
      pane = atom.workspace.paneForItem(paneItem)
      if not pane?
        return

      @_pathHistory = @_pathHistory[0..@_currentIndexInHistory]
      @_pathHistory.push [pane, path]

      @_currentIndexInHistory++

  _removeExtraHistory: ->
    while @_pathHistory.length > @_maxPathsToRemember
      @_pathHistory.shift()

  _getForwardPathInHistory: ->
    activePane = atom.workspace.getActivePane()
    activePath = activePane.getActiveItem?().getPath?()

    if @_currentIndexInHistory >= @_pathHistory.length - 1
      return [null, -1]

    for i in [@_currentIndexInHistory + 1...@_pathHistory.length]
      [pane, path] = @_pathHistory[i]

      if path == activePath
        continue

      if pane == activePane
        return [path, i]

    return [null, -1]

  _getBackwardPathInHistory: ->
    activePane = atom.workspace.getActivePane()
    activePath = activePane.getActiveItem?().getPath?()

    if @_currentIndexInHistory <= 0
      return [null, -1]

    for i in [@_currentIndexInHistory - 1..0]
      [pane, path] = @_pathHistory[i]

      if path == activePath
        continue

      if pane == activePane
        return [path, i]

    return [null, -1]
