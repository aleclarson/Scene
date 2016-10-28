
{Type, Style} = require "modx"
{View} = require "modx/views"

SortedArray = require "sorted-array"
assertType = require "assertType"
isType = require "isType"
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

    if Array.isArray scene
      scene.forEach @insert.bind this
      return

    assertType scene, Scene.Kind

    if scene.collection is this
      return # Already in this collection!

    if scene.collection isnt null
      throw Error "Scenes can only belong to one collection at a time!"

    scene._collection = this
    scene.__onInsert this

    @_scenes.insert scene
    @view and @view.forceUpdate()
    return

  remove: (scene) ->

    assertType scene, Scene.Kind

    if scene.collection isnt this
      throw Error "Scene does not belong to this collection!"

    scene.__onRemove this
    scene._collection = null

    index = @_scenes.array.indexOf scene
    @_scenes.array.splice index, 1

    delete @_elements[scene.__name]
    @view and @view.forceUpdate()
    return

  searchBelow: (scene, filter) ->

    assertType scene, Scene.Kind

    if scene.collection isnt this
      throw Error "Scene does not belong to this collection!"

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

type.render ->

  cache = @_elements
  children = sync.map @_scenes.array, (scene) ->
    key = scene.__name # TODO: Replace this with a random ID generated by the Scene constructor?
    return cache[key] if cache[key]
    cache[key] = scene.render {key}

  return View
    style: @props.style
    children: children

type.shouldUpdate -> no

module.exports = type.build()
