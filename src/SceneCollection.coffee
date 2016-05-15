
{ Component } = require "component"

SortedArray = require "sorted-array"
assertType = require "assertType"
isType = require "isType"

Scene = require "./Scene"

type = Component.Type "SceneCollection"

type.loadComponent ->
  require "./SceneCollectionView"

type.defineProperties

  scenes: get: ->
    @_scenes.array

  visibleScenes: get: ->
    @scenes.filter (s) -> not s.isHidden

  hiddenScenes: get: ->
    @scenes.filter (s) -> s.isHidden

type.defineValues

  _view: null

  _elements: -> {}

  _scenes: -> SortedArray.comparing "level"

type.defineMethods

  insert: (scene) ->

    assertType scene, Scene.Kind
    assert scene.collection is null, "Scenes can only belong to one collection at a time!"

    scene.collection = this
    scene.__onInsert this

    @_scenes.insert scene
    @_view.forceUpdate() if @_view
    return

  remove: (scene) ->

    assertType scene, Scene.Kind
    assert scene.collection is this, "Scene does not belong to this collection!"

    scene.__onRemove this
    scene.collection = null

    @_scenes.remove scene
    delete @_elements[scene.__id]
    @_view.forceUpdate() if @_view
    return

  searchBelow: (scene, filter) ->

    assertType scene, Scene.Kind
    assert scene.collection is this, "Scene does not belong to this collection!"

    filter ?= emptyFunction.thatReturnsTrue

    results = []

    for result in @_scenes.array

      return if result is scene

      continue unless filter result

      results.push result

    return results

module.exports = type.build()
