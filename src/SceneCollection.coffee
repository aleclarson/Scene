
{Type, Style} = require "modx"
{View} = require "modx/views"

SortedArray = require "sorted-array"
assertType = require "assertType"
isType = require "isType"
assert = require "assert"
sync = require "sync"

Scene = require "./Scene"

type = Type "SceneCollection"

type.defineValues

  _elements: -> {}

  _scenes: -> SortedArray.comparing "level"

type.defineGetters

  scenes: ->
    @_scenes.array

  visibleScenes: ->
    @scenes.filter (scene) ->
      not scene.isHidden

  hiddenScenes: ->
    @scenes.filter (scene) ->
      scene.isHidden

type.defineMethods

  insert: (scene) ->

    assertType scene, Scene.Kind
    assert scene.collection is null, "Scenes can only belong to one collection at a time!"

    log.it @__name + ".insert: " + scene.__name
    scene._collection = this
    scene.__onInsert this

    @_scenes.insert scene
    @view and @view.forceUpdate()
    return

  remove: (scene) ->

    assertType scene, Scene.Kind
    assert scene.collection is this, "Scene does not belong to this collection!"

    scene.__onRemove this
    scene._collection = null

    @_scenes.remove scene
    delete @_elements[scene.__name]
    @view.forceUpdate() if @view
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

type.defineProps
  style: Style

type.shouldUpdate ->
  return no

type.render ->

  cache = @_elements
  children = sync.map @_scenes.array, (scene) ->
    key = scene.__name
    return cache[key] if cache[key]
    cache[key] = scene.render { key }

  return View
    style: @props.style
    children: children

module.exports = type.build()
