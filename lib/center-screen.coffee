module.exports =

  activate: (state) ->
    {EditorView} = require 'atom'

    EditorView::scrollVertically = (pixelPosition, {center}={}) ->
      scrollViewHeight = @scrollView.height()
      scrollTop = @scrollTop()
      scrollBottom = scrollTop + scrollViewHeight

      if center
        @scrollTop(pixelPosition.top - (scrollViewHeight / 2))
      else
        linesInView = @scrollView.height() / @lineHeight
        maxScrollMargin = Math.floor((linesInView - 1) / 2)
        scrollMargin = Math.min(@vScrollMargin, maxScrollMargin)
        margin = scrollMargin * @lineHeight
        desiredTop = pixelPosition.top - margin
        desiredBottom = pixelPosition.top + @lineHeight + margin
        if desiredBottom > scrollBottom
          @scrollTop(desiredBottom - scrollViewHeight)
        else if desiredTop < scrollTop
          @scrollTop(desiredTop)

    EditorView::updateLayerDimensions = ->
      height = @lineHeight * @editor.getScreenLineCount()
      if @closest(".pane").length > 0 && atom.workspaceView.getActiveView() instanceof EditorView
        height = height + @height() / 2
      if @layerHeight != height
        @layerHeight = height
        @underlayer.height(@layerHeight)
        @renderedLines.height(@layerHeight)
        @overlayer.height(@layerHeight)
        @verticalScrollbarContent.height(@layerHeight)
        if @scrollBottom() > height
          @scrollBottom(height)
      minWidth = Math.max(@charWidth * @editor.getMaxScreenLineLength() + 20, @scrollView.width())
      if @layerMinWidth != minWidth
        @renderedLines.css('min-width', minWidth)
        @underlayer.css('min-width', minWidth)
        @overlayer.css('min-width', minWidth)
        @layerMinWidth = minWidth
        @trigger('editor:min-width-changed')

    atom.workspaceView.command 'center-screen:center-screen', =>
      @centerScreen()

  cursorLine: ->
    atom.workspace.getActiveEditor().getCursorScreenRow()

  centerScreen: ->
    atom.workspaceView.getActiveView().scrollToScreenPosition(
      [@cursorLine(), 0],
      { center: true }
    );
