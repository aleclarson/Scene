
require "isDev"

{ throwFailure } = require "failure"
{ Component } = require "component"

emptyFunction = require "emptyFunction"
getArgProp = require "getArgProp"

type = Component.Type "Scene"

type.loadComponent ->
  require "./SceneView"

type.defineStatics

  Chain: lazy: ->
    require "./SceneChain"

  Collection: lazy: ->
    require "./SceneCollection"

if isDev
  global.scenes = Object.create null
  type.initInstance -> global.scenes[@__id] = this

type.optionTypes =
  level: Number
  isHidden: Boolean
  ignoreTouches: Boolean
  ignoreTouchesBelow: Boolean

type.optionDefaults =
  level: 0
  isHidden: yes
  ignoreTouches: no
  ignoreTouchesBelow: no

type.defineReactiveValues

  _level: getArgProp "level"

  isHidden: getArgProp "isHidden"

  ignoreTouches: getArgProp "ignoreTouches"

  ignoreTouchesBelow: getArgProp "ignoreTouchesBelow"

type.defineValues

  _chain: null

  _collection: null

type.exposeGetters [
  "chain"
  "collection"
]

type.defineProperties

  level:
    get: -> @_level
    set: -> # TODO: Implement scene.level setting

  isActive: get: ->
    return no unless @_chain
    return this is @_chain.last

type.defineMethods

  __onInsert: emptyFunction

  __onActive: emptyFunction

  __onInactive: emptyFunction

  __onRemove: emptyFunction

type.defineStyles

  container:
    presets: [ "cover", "clear" ]
    opacity: -> @view.opacity

  background:
    presets: [ "cover", "clear" ]

  content:
    presets: [ "cover", "clear" ]
    scale: -> @view.scale

module.exports = type.build()
