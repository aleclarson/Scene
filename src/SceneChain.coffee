
assertType = require "assertType"
fromArgs = require "fromArgs"
assert = require "assert"
Type = require "Type"
sync = require "sync"

SceneCollection = require "./SceneCollection"
Scene = require "./Scene"

type = Type "SceneChain"

type.defineOptions
  isHidden: Boolean.withDefault no
  collection: SceneCollection

type.defineValues

  scenes: -> []

  _collection: fromArgs "collection"

type.defineReactiveValues

  isHidden: fromArgs "isHidden"

  last: null

type.definePrototype

  collection:
    get: -> @_collection
    set: (newValue, oldValue) ->
      @_collection = newValue
      if newValue
        if oldValue
          sync.each @scenes, (scene) ->
            oldValue.remove scene
            newValue.insert scene
        else
          sync.each @scenes, (scene) ->
            newValue.insert scene
      else if oldValue
        sync.each @scenes, (scene) ->
          oldValue.remove scene
      return

type.defineMethods

  push: (scene) ->

    assertType scene, Scene.Kind
    assert scene.chain is null, "Scenes can only belong to one chain at a time!"

    @last and
    @last.__onInactive this

    scene._chain = this
    scene.__onActive this

    @scenes.push scene
    @last = scene

    @_collection and
    @_collection.insert scene
    return

  pop: ->

    { length } = @scenes
    return if length is 0

    scene = @scenes.pop()
    scene.__onInactive this
    scene._chain = null

    @_collection and
    @_collection.remove scene

    if length is 1
      @last = null
      return

    @last = @scenes[length - 2]
    @last.__onActive this
    return

module.exports = type.build()
