
assertType = require "assertType"
isType = require "isType"
Type = require "Type"

SceneTree = require "./SceneTree"
Scene = require "./Scene"

type = Type "SceneChain"

type.defineArgs
  isHidden: Boolean

type.defineReactiveValues (options) ->

  isHidden: options.isHidden is yes

type.defineGetters

  length: -> @_length

  current: -> @_current

  scenes: ->
    if @_current
    then @_scenes.concat @_current
    else []

type.defineMethods

  push: (scene, options) ->
    assertType scene, Scene.Kind
    assertType options, Object.Maybe

    if scene.chain isnt null
      throw Error "Scenes can only belong to one chain at a time!"

    if @_current isnt null
      @_current.__onInactive()
      @_scenes.push @_current

    @_length += 1
    scene._chain = this
    scene.__onActive options
    @_current = scene
    return

  pop: ->

    if @_current is null
      return null

    scene = @_current
    scene._chain = null
    scene.__onInactive()
    @_length -= 1

    if current = @_scenes.pop()
      current.__onActive()
      @_current = current
      return scene

    @_current = null
    return scene

type.defineStatics

  find: (view) ->
    SceneTree.findChain view

#
# Internals
#

type.defineValues ->

  _scenes: []

  _length: 0

type.defineReactiveValues

  _current: null

module.exports = type.build()
