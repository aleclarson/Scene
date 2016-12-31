###
@providesModule SceneTree
###

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
    inst = ReactInstanceMap.get view
    while inst
      tag = ReactNativeComponentTree.getNodeFromInstance inst
      if scene = @_tree[tag]
        return scene if filter scene
      inst = ReactNativeTreeTraversal.getParentInstance inst
    return null

  findSceneChain: (view) ->
    if scene = @findScene view, belongsToChain
    then scene.chain
    else null

  findSceneCollection: (view) ->
    if scene = @findScene view, belongsToCollection
    then scene.collection
    else null

  _addScene: (scene) ->
    throw Error "Scene must be mounted!" unless scene.view
    inst = ReactInstanceMap.get scene.view
    tag = ReactNativeComponentTree.getNodeFromInstance inst
    @_tree[tag] = scene
    return

  _removeScene: (scene) ->
    throw Error "Scene must be mounted!" unless scene.view
    inst = ReactInstanceMap.get scene.view
    tag = ReactNativeComponentTree.getNodeFromInstance inst
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
