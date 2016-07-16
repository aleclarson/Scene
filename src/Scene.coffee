
require "isDev"

{ Component, Style, Children, View } = require "component"

emptyFunction = require "emptyFunction"
fromArgs = require "fromArgs"

type = Component.Type "Scene"

type.defineOptions

  level:
    type: Number
    default: 0

  isHidden:
    type: Boolean
    default: yes

  ignoreTouches:
    type: Boolean
    default: no

  ignoreTouchesBelow:
    type: Boolean
    default: no

if isDev
  global.scenes = Object.create null
  type.initInstance ->
    global.scenes[@__name] = this

type.defineReactiveValues

  isHidden: fromArgs "isHidden"

  ignoreTouches: fromArgs "ignoreTouches"

  ignoreTouchesBelow: fromArgs "ignoreTouchesBelow"

  _level: fromArgs "level"

type.defineValues

  _chain: null

  _collection: null

type.exposeGetters [
  "chain"
  "collection"
]

type.definePrototype

  level:
    get: -> @_level
    set: ->
      # TODO: Implement scene.level setting
      throw Error "Unimplemented!"

  isActive: get: ->
    return no unless @_chain
    return this is @_chain.last

  isTouchable: get: ->
    return no if @ignoreTouches
    return yes

  isTouchableBelow: get: ->
    return no if @ignoreTouchesBelow
    return yes if @ignoreTouches
    return yes

type.defineMethods

  __onInsert: emptyFunction

  __onActive: emptyFunction

  __onInactive: emptyFunction

  __onRemove: emptyFunction

type.defineStatics

  Chain: lazy: ->
    require "./SceneChain"

  Collection: lazy: ->
    require "./SceneCollection"

#
# Rendering
#

type.propTypes =
  style: Style
  children: Children

type.defineNativeValues

  scale: 1

  opacity: -> =>
    if @isHidden then 0 else 1

  containerEvents: -> =>
    if @isHidden then "none" else "box-none"

  contentEvents: -> =>
    if @isTouchable then "box-none" else "none"

  backgroundEvents: -> =>
    if @isTouchableBelow then "none" else "auto"

type.defineStyles

  container:
    cover: yes
    clear: yes
    opacity: -> @opacity

  background:
    cover: yes
    clear: yes

  content:
    cover: yes
    clear: yes
    scale: -> @scale

type.render ->
  return View
    style: @styles.container()
    pointerEvents: @containerEvents
    children: [
      @__renderBackground()
      @__renderContent()
    ]

type.defineMethods

  __renderChildren: ->
    @props.children

  __renderContent: ->
    return View
      children: @__renderChildren()
      pointerEvents: @contentEvents
      style: [
        @styles.content()
        @props.style
      ]

  __renderBackground: ->
    return View
      style: @styles.background()
      pointerEvents: @backgroundEvents
      onStartShouldSetResponder: emptyFunction.thatReturnsTrue

module.exports = type.build()
