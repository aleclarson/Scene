
assertType = require "assertType"
Type = require "Type"
sync = require "sync"

SceneTree = require "./SceneTree"
Scene = require "./Scene"

type = Type "SceneChain"

type.defineStatics
  find: (view) -> SceneTree.findChain view

type.defineOptions
  isHidden: Boolean.withDefault no
  parent: Scene.Kind

type.defineValues (options) ->

  _scenes: []

  _parent: options.parent

type.defineReactiveValues (options) ->

  isHidden: options.isHidden

  _last: null

type.defineGetters

  last: -> @_last

  scenes: -> @_scenes

type.defineMethods

  push: (scene) ->

    assertType scene, Scene.Kind

    if scene.chain isnt null
      throw Error "Scenes can only belong to one chain at a time!"

    if @_last
      @_last.__onInactive this

    scene._chain = this
    scene.__onActive this

    @_scenes.push scene
    @_last = scene
    return

  pop: ->

    sceneCount = @_scenes.length
    return if sceneCount is 0

    scene = @_scenes.pop()
    scene.__onInactive this
    scene._chain = null

    if sceneCount is 1
      @_last = null
      return

    @_last = @_scenes[sceneCount - 2]
    @_last.__onActive this
    return

  remove: (scene) ->

    assertType scene, Scene.Kind

    if scene is @_last
      return @pop()

    index = @_scenes.indexOf scene
    @_scenes.splice index, 1

    scene.__onInactive this
    scene._chain = null
    return

module.exports = type.build()
