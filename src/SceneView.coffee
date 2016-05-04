
{ Style, Children, Component, View } = require "component"

emptyFunction = require "emptyFunction"

Scene = require "./Scene"

type = Component()

type.contextType = Scene

type.propTypes =
  style: Style
  children: Children

type.defineProperties

  isTouchable: get: ->
    return no if @ignoreTouches
    return yes

  isTouchableBelow: get: ->
    return no if @ignoreTouchesBelow
    return yes if @ignoreTouches
    return yes

type.defineNativeValues

  scale: 1

  opacity: -> =>
    if @isHidden then 0 else 1

  containerEvents: -> =>
    if @isHidden then "none" else "box-none"

  contentEvents: -> =>
    if @view.isTouchable then "box-none" else "none"

  backgroundEvents: -> =>
    if @view.isTouchableBelow then "none" else "auto"

type.render (props) ->

  background = View
    style: @styles.background
    pointerEvents: @view.backgroundEvents
    onStartShouldSetResponder: emptyFunction.thatReturnsTrue

  content = View
    style: [ @styles.content, props.style ]
    children: props.children
    pointerEvents: @view.contentEvents

  return View
    style: @styles.container
    children: [ background, content ]
    pointerEvents: @view.containerEvents

module.exports = type.build()
