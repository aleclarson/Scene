
require "isDev"

{Type, Style, Children} = require "modx"
{View} = require "modx/views"

emptyFunction = require "emptyFunction"

type = Type "Scene"

type.defineOptions
  level: Number.withDefault 0
  isHidden: Boolean.withDefault no
  isPermanent: Boolean.withDefault no
  ignoreTouches: Boolean.withDefault no
  ignoreTouchesBelow: Boolean.withDefault no

if isDev
  global.scenes = Object.create null
  type.initInstance ->
    global.scenes[@__name] = this

type.defineReactiveValues (options) ->

  isHidden: options.isHidden

  isPermanent: options.isPermanent

  ignoreTouches: options.ignoreTouches

  ignoreTouchesBelow: options.ignoreTouchesBelow

  _level: options.level

  _chain: null

  _collection: null

type.defineGetters

  chain: -> @_chain

  collection: -> @_collection

  isTouchable: ->
    return no if @ignoreTouches
    return yes

  isTouchableBelow: ->
    return no if @ignoreTouchesBelow
    return yes if @ignoreTouches
    return yes

type.definePrototype

  level:
    get: -> @_level
    set: ->
      # TODO: Implement scene.level setting
      throw Error "Unimplemented!"

type.defineHooks

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
    return 0 if @_chain and @_chain.isHidden
    return 0 if @isHidden
    return 1

  containerEvents: -> =>
    return "none" if @_chain and @_chain.isHidden
    return "none" if @isHidden
    return "box-none"

  contentEvents: -> =>
    return "box-none" if @isTouchable
    return "none"

  backgroundEvents: -> =>
    return "none" if @isTouchableBelow
    return "auto"

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

type.defineHooks

  __renderChildren: ->
    @props.children

  __renderContent: ->
    return View
      style: @styles.content()
      pointerEvents: @contentEvents
      children: @__renderChildren()

  __renderBackground: ->
    return View
      style: @styles.background()
      pointerEvents: @backgroundEvents
      onStartShouldSetResponder: emptyFunction.thatReturnsTrue

module.exports = type.build()
