
{Style, Children} = require "react-validators"

ReactUpdateQueue = require "react-native/lib/ReactUpdateQueue"
emptyFunction = require "emptyFunction"
Event = require "eve"
View = require "modx/lib/View"
modx = require "modx"

SceneTree = require "./SceneTree"

type = modx.Type "Scene"

type.defineStatics
  find: (view) -> SceneTree.findScene view
  Chain: lazy: -> require "./SceneChain"
  Collection: lazy: -> require "./SceneCollection"
  Router: lazy: -> require "./SceneRouter"

type.defineArgs
  level: Number
  isHidden: Boolean
  isPermanent: Boolean
  ignoreTouches: Boolean
  ignoreTouchesBelow: Boolean

type.defineFrozenValues ->

  didMount: Event()

  didUpdate: Event()

type.defineReactiveValues (options) ->

  isHidden: options.isHidden is yes

  isPermanent: options.isPermanent is yes

  ignoreTouches: options.ignoreTouches is yes

  ignoreTouchesBelow: options.ignoreTouchesBelow is yes

  _level: options.level ? 0

  _chain: null

  _collection: null

type.defineReactions

  _containerOpacity: ->
    return 0 if @_chain and @_chain.isHidden
    return 0 if @isHidden
    return 1

  _containerEvents: ->
    return "none" if @_chain and @_chain.isHidden
    return "none" if @isHidden
    return "box-none"

  _foregroundEvents: ->
    return "box-none" if @isTouchable
    return "none"

  _backgroundEvents: ->
    return "none" if @isTouchableBelow
    return "auto"

#
# Prototype
#

type.defineGetters

  chain: -> @_chain

  collection: -> @_collection

  isTouchable: -> not @ignoreTouches

  isTouchableBelow: -> @ignoreTouches or not @ignoreTouchesBelow

type.definePrototype

  level:
    get: -> @_level
    set: (newValue) ->
      # TODO: Allow setting 'level' when mounted?
      if @view then throw Error "Cannot set scene level while mounted!"
      @_level = newValue

type.defineMethods

  onceMounted: (callback) ->
    if @view and ReactUpdateQueue.isMounted @view
    then callback()
    else @didMount.once callback

type.defineHooks

  __onInsert: emptyFunction

  __onActive: emptyFunction

  __onInactive: emptyFunction

  __onRemove: emptyFunction

type.didMount ->
  SceneTree._addScene this
  @didMount.emit()

type.didUpdate ->
  @didUpdate.emit()

type.willUnmount ->
  SceneTree._removeScene this

#
# Rendering
#

type.defineProps
  style: Style
  children: Children

type.render ->

  background = View
    style: containerStyle
    pointerEvents: @_backgroundEvents
    onStartShouldSetResponder: emptyFunction.thatReturnsTrue
    children: @__renderBackground()

  foreground = View
    style: containerStyle
    pointerEvents: @_foregroundEvents
    children: @__renderForeground()

  return View
    pointerEvents: @_containerEvents
    style: [
      containerStyle
      opacity: @_containerOpacity
    ]
    children: [
      background
      foreground
    ]

type.defineHooks

  __renderForeground: -> @props.children

  __renderBackground: emptyFunction

module.exports = Scene = type.build()

containerStyle =
  position: "absolute"
  top: 0
  left: 0
  right: 0
  bottom: 0
  backgroundColor: "transparent"
