CenterScreen = require './center-screen'
module.exports =
  configDefaults:
    followCursor: false

  activate: ->
    atom.workspaceView.command 'center-screen:toggle-follow-cursor', =>
      @toggleFollowCursor()

    atom.workspaceView.eachEditorView (editorView) ->
      if editorView.attached and editorView.getPane()?
        new CenterScreen(editorView)

  toggleFollowCursor: ->
    followCursor = not atom.config.get('center-screen.followCursor')
    atom.config.set('center-screen.followCursor', followCursor)
