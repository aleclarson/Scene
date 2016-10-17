
{Type, Style, Children} = require "modx"
{View} = require "modx/views"

emptyFunction = require "emptyFunction"
isDev = require "isDev"

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

  isTouchable: ->
    return no if @ignoreTouches
    return yes

  isTouchableBelow: ->
    return no if @ignoreTouchesBelow
    return yes if @ignoreTouches
    return yes

type.definePrototype

  collection:
    get: -> @_collection
    set: (newValue) ->
      if newValue is null
        @_collection.remove this
      else newValue.insert this

  level:
    get: -> @_level
    set: (newValue) ->
      # TODO: Allow setting 'level' when mounted?
      if @view then throw Error "Cannot set scene level while mounted!"
      @_level = newValue

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

type.defineProps
  style: Style
  children: Children

type.defineNativeValues

  _containerOpacity: ->
    return 0 if @_chain and @_chain.isHidden
    return 0 if @isHidden
    return 1

  _containerEvents: ->
    return "none" if @_chain and @_chain.isHidden
    return "none" if @isHidden
    return "box-none"

  _contentEvents: ->
    return "box-none" if @isTouchable
    return "none"

  _backgroundEvents: ->
    return "none" if @isTouchableBelow
    return "auto"

type.defineStyles

  container:
    cover: yes
    clear: yes
    opacity: -> @_containerOpacity

  background:
    cover: yes
    clear: yes

  content:
    cover: yes
    clear: yes

type.render ->
  return View
    style: @styles.container()
    pointerEvents: @_containerEvents
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
      pointerEvents: @_contentEvents
      children: @__renderChildren()

  __renderBackground: ->
    return View
      style: @styles.background()
      pointerEvents: @_backgroundEvents
      onStartShouldSetResponder: emptyFunction.thatReturnsTrue

module.exports = type.build()
