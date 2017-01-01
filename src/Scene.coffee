
{Style, Children} = require "react-validators"

ReactUpdateQueue = require "ReactUpdateQueue"
emptyFunction = require "emptyFunction"
Event = require "Event"
View = require "modx/lib/View"
modx = require "modx"

SceneTree = require "./SceneTree"

type = modx.Type "Scene"

type.defineStatics
  Tree: lazy: -> require "./SceneTree"
  Chain: lazy: -> require "./SceneChain"
  Collection: lazy: -> require "./SceneCollection"

type.defineOptions
  level: Number.withDefault 0
  isHidden: Boolean.withDefault no
  isPermanent: Boolean.withDefault no
  ignoreTouches: Boolean.withDefault no
  ignoreTouchesBelow: Boolean.withDefault no

type.defineFrozenValues ->

  didMount: Event()

  didUpdate: Event()

type.defineReactiveValues (options) ->

  isHidden: options.isHidden

  isPermanent: options.isPermanent

  ignoreTouches: options.ignoreTouches

  ignoreTouchesBelow: options.ignoreTouchesBelow

  _level: options.level

  _chain: null

  _collection: null

type.initInstance (options) ->
  @chain = options.chain
  @collection = options.collection
  return

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

  parent: ->
    return @_chain._parent if @_chain
    return @_collection._parent if @_collection
    return null

  isTouchable: -> not @ignoreTouches

  isTouchableBelow: -> @ignoreTouches or not @ignoreTouchesBelow

type.definePrototype

  chain:
    get: -> @_chain
    set: (newValue, oldValue) ->
      if newValue isnt oldValue
        oldValue?.remove this
        if newValue?
          assertType newValue, Scene.Chain
          newValue.push this
      return

  collection:
    get: -> @_collection
    set: (newValue, oldValue) ->
      if newValue isnt oldValue
        oldValue?.remove this
        if newValue?
          assertType newValue, Scene.Collection
          newValue.insert this
      return

  level:
    get: -> @_level
    set: (newValue) ->
      # TODO: Allow setting 'level' when mounted?
      if @view then throw Error "Cannot set scene level while mounted!"
      @_level = newValue

type.defineMethods

  onceMounted: (callback) ->

    if @view and ReactUpdateQueue.isMounted @view
      callback()
      return

    listener = @didMount 1, callback
    return listener.start()

type.defineHooks

  __onInsert: emptyFunction

  __onActive: emptyFunction

  __onInactive: emptyFunction

  __onRemove: emptyFunction

#
# Rendering
#

type.defineProps
  style: Style
  children: Children

type.didMount ->
  SceneTree._addScene this
  @didMount.emit()

type.willUnmount ->
  SceneTree._removeScene this

type.didUpdate ->
  @didUpdate.emit()

type.render ->
  return View
    style: @styles.container()
    pointerEvents: @_containerEvents
    children: [
      @_renderBackground()
      @_renderForeground()
    ]

type.defineMethods

  _renderBackground: ->
    return View
      style: @styles.background()
      pointerEvents: @_backgroundEvents
      onStartShouldSetResponder: emptyFunction.thatReturnsTrue
      children: @__renderBackground()

  _renderForeground: ->
    return View
      style: @styles.foreground()
      pointerEvents: @_foregroundEvents
      children: @__renderForeground()

type.defineHooks

  __renderForeground: -> @props.children

  __renderBackground: emptyFunction

type.defineStyles

  container:
    cover: yes
    clear: yes
    opacity: -> @_containerOpacity

  background:
    cover: yes
    clear: yes

  foreground:
    cover: yes
    clear: yes

module.exports = Scene = type.build()
