
assertType = require "assertType"
assert = require "assert"
Type = require "Type"

Scene = require "./Scene"

type = Type "SceneChain"

type.defineValues

  scenes: -> []

type.defineReactiveValues

  last: null

type.defineMethods

  push: (scene) ->

    assertType scene, Scene.Kind
    assert scene.chain is null, "Scenes can only belong to one chain at a time!"

    @last.__onInactive this if @last

    scene._chain = this
    scene.__onActive this

    @scenes.push scene
    @last = scene
    return

  pop: ->

    { length } = @scenes
    if length is 0
      return

    scene = @scenes.pop()
    scene.__onInactive this
    scene._chain = null

    if length is 1
      @last = null
      return

    @last = @scenes[length - 2]
    @last.__onActive this
    return

module.exports = type.build()
