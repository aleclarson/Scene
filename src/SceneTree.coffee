
ReactNativeComponentTree = require "ReactNativeComponentTree"
ReactNativeTreeTraversal = require "ReactNativeTreeTraversal"
ReactInstanceMap = require "ReactInstanceMap"
ReactComponent = require "ReactComponent"
emptyFunction = require "emptyFunction"
Type = require "Type"

type = Type "SceneTree"

type.defineValues ->

  _tree: Object.create null

type.defineMethods

  findScene: (view, filter = emptyFunction.thatReturnsTrue) ->
    assertView view
    inst = getNativeInstance view
    while inst
      tag = ReactNativeComponentTree.getNodeFromInstance inst
      if scene = @_tree[tag]
        return scene if filter scene
      inst = ReactNativeTreeTraversal.getParentInstance inst
    return null

  findChain: (view) ->
    if scene = @findScene view, belongsToChain
    then scene.chain
    else null

  findCollection: (view) ->
    if scene = @findScene view, belongsToCollection
    then scene.collection
    else null

  _addScene: (scene) ->

    unless scene.view
      throw Error "Scene must be mounted!"

    tag = getNativeTag scene.view
    unless @_tree[tag]
      @_tree[tag] = scene
      return

    throw Error "Scene with tag '#{tag}' already exists!"

  _removeScene: (scene) ->

    unless scene.view
      throw Error "Scene must be mounted!"

    tag = getNativeTag scene.view
    delete @_tree[tag]

module.exports = type.construct()

#
# Helpers
#

assertView = (view) ->
  unless view instanceof ReactComponent
    throw TypeError "'view' must be a kind of ReactComponent"

belongsToChain = (scene) ->
  scene.chain isnt null

belongsToCollection = (scene) ->
  scene.collection isnt null

getNativeInstance = (view) ->
  inst = ReactInstanceMap.get view
  inst = next while next = inst._renderedComponent
  return inst

getNativeTag = (view) ->
  inst = getNativeInstance view
  return ReactNativeComponentTree.getNodeFromInstance inst
