{Subscriber} = require 'emissary'

module.exports =
class CenterScreen
  Subscriber.includeInto(this)

  constructor: (@editorView) ->

    DisplayBuffer = require "src/display-buffer"
    DisplayBuffer::getScrollHeight = ->
      lineHeight = if @getLineHeight then @getLineHeight() else @getLineHeightInPixels()
      if not lineHeight > 0
        throw new Error("You must assign lineHeight before calling ::getScrollHeight()")
      height = @getLineCount() * lineHeight
      height = height + @getHeight() / 2
      height

    DisplayBuffer::scrollToScreenRange = (screenRange, options) ->
      verticalScrollMarginInPixels = @getVerticalScrollMargin() * @getLineHeightInPixels()
      horizontalScrollMarginInPixels = @getHorizontalScrollMargin() * @getDefaultCharWidth()

      {top, left, height, width} = @pixelRectForScreenRange(screenRange)
      bottom = top + height
      right = left + width

      if options?.center
        desiredScrollCenter = top + height / 2
        desiredScrollTop =  desiredScrollCenter - @getHeight() / 2
        desiredScrollBottom =  desiredScrollCenter + @getHeight() / 2
      else
        desiredScrollTop = top - verticalScrollMarginInPixels
        desiredScrollBottom = bottom + verticalScrollMarginInPixels

      desiredScrollLeft = left - horizontalScrollMarginInPixels
      desiredScrollRight = right + horizontalScrollMarginInPixels

      if desiredScrollTop < @getScrollTop()
        @setScrollTop(desiredScrollTop)
      else if desiredScrollBottom > @getScrollBottom()
        @setScrollBottom(desiredScrollBottom)

      if desiredScrollLeft < @getScrollLeft()
        @setScrollLeft(desiredScrollLeft)
      else if desiredScrollRight > @getScrollRight()
        @setScrollRight(desiredScrollRight)

    EditorView = require "src/editor-view"
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

    @subscribe atom.config.observe 'center-screen.followCursor', callNow:false, =>
      @updateSubscription()

    @updateSubscription()

    atom.workspaceView.command 'center-screen:center-screen', =>
      @centerScreen()

  cursorLine: ->
    atom.workspace.getActiveEditor()?.getCursorScreenRow()

  centerScreen: ->
    line = @cursorLine()
    if line
      atom.workspaceView.getActiveView().scrollToScreenPosition(
        [line, 0],
        { center: true }
      )

  followCursorConfig: ->
    atom.config.get('center-screen.followCursor')

  updateSubscription: ->
    followCursor = @followCursorConfig()
    if followCursor
      @subscribe @editorView, 'cursor:moved', =>
        @centerScreen()
      @centerScreen()
    else
        @unsubscribe @editorView
