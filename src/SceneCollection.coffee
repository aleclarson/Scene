
{Style} = require "react-validators"

SortedArray = require "sorted-array"
assertType = require "assertType"
ReactType = require "modx/lib/Type"
View = require "modx/lib/View"
sync = require "sync"

Scene = require "./Scene"

type = ReactType "SceneCollection"

type.defineOptions
  parent: Scene.Kind

type.defineValues (options) ->

  _parent: options.parent

  _elements: {}

  _scenes: SortedArray.comparing "level"

type.defineGetters

  array: ->
    @_scenes.array

  visible: ->
    @_scenes.array
      .filter (scene) ->
        not scene.isHidden

  hidden: ->
    @_scenes.array
      .filter (scene) ->
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

  keys = [] if isDev
  elements = @_elements
  children = sync.map @_scenes.array, (scene) ->
    key = scene.__name

    if isDev
      if 0 <= keys.indexOf key
        throw Error "Duplicate scene name: '#{key}'"
      keys.push key

    elements[key] or
    elements[key] = scene.render {key}

  return View
    style: @props.style
    children: children

type.shouldUpdate -> no

module.exports = type.build()
