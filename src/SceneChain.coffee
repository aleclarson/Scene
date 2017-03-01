
assertType = require "assertType"
Type = require "Type"
sync = require "sync"

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

    if @_last
      @_last.__onInactive this

    scene._chain = this
    scene.__onActive this

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
    scene._chain = null
    scene.__onInactive this

    if sceneCount is 1
      @_last = null
      return

    if @_paths.length
      @_paths.pop()
      @_path = @_paths[sceneCount - 2]

    @_last = @_scenes[sceneCount - 2]
    @_last.__onActive this
    return

  remove: (scene) ->

    assertType scene, Scene.Kind

    if scene is @_last
      return @pop()

    index = @_scenes.indexOf scene
    @_scenes.splice index, 1

    scene._chain = null
    scene.__onInactive this
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
