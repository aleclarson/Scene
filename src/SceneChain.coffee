
assertType = require "assertType"
Type = require "Type"

SceneTree = require "./SceneTree"
Scene = require "./Scene"

type = Type "SceneChain"

type.defineStatics
  find: (view) -> SceneTree.findChain view

type.defineArgs
  isHidden: Boolean

type.defineReactiveValues (options) ->

  isHidden: options.isHidden is yes

type.defineGetters

  path: -> @_path

  last: -> @_last

  scenes: -> @_scenes

type.defineMethods

  push: (scene, path) ->
    assertType scene, Scene.Kind
    assertType path, String.Maybe

    if scene.chain isnt null
      throw Error "Scenes can only belong to one chain at a time!"

    if @_last isnt null
      @_last.__onInactive()

    scene._chain = this
    scene.__onActive()

    if path
      @_paths.push path
      @_path = path

    @_scenes.push scene
    @_last = scene
    return

  pop: ->

    sceneCount = @_scenes.length
    return if sceneCount is 0

    scene = @_scenes.pop()
    scene.__onInactive()
    scene._chain = null

    if sceneCount is 1
      @_last = null
      return

    if @_paths.length
      @_paths.pop()
      @_path = @_paths[sceneCount - 2]

    @_last = @_scenes[sceneCount - 2]
    @_last.__onActive()
    return

#
# Internals
#

type.defineValues ->

  _paths: []

  _scenes: []

type.defineReactiveValues

  _path: null

  _last: null

module.exports = type.build()
