
{ Component, Style, View } = require "component"

SortedArray = require "sorted-array"
assertType = require "assertType"
isType = require "isType"
assert = require "assert"

Scene = require "./Scene"

type = Component.Type "SceneCollection"

type.defineProperties

  scenes: get: ->
    @_scenes.array

  visibleScenes: get: ->
    @scenes.filter (scene) ->
      not scene.isHidden

  hiddenScenes: get: ->
    @scenes.filter (scene) ->
      scene.isHidden

type.defineValues

  _view: null

  _elements: -> {}

  _scenes: -> SortedArray.comparing "level"

type.defineMethods

  insert: (scene) ->

    assertType scene, Scene.Kind
    assert scene.collection is null, "Scenes can only belong to one collection at a time!"

    scene._collection = this
    scene.__onInsert this

    @_scenes.insert scene
    @_view.forceUpdate() if @_view
    return

  remove: (scene) ->

    assertType scene, Scene.Kind
    assert scene.collection is this, "Scene does not belong to this collection!"

    scene.__onRemove this
    scene._collection = null

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

#
# Rendering
#

type.propTypes =
  style: Style

type.shouldUpdate ->
  return no

type.render (props) ->

  children = []
  for scene in @_scenes.array
    children.push @_elements[scene.__name] ?= scene._render { key: scene.__name }

  return View
    style: props.style
    children: children

module.exports = type.build()
