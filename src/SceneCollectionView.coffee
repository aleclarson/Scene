
{ Component, Style, View } = require "component"

SceneCollection = require "./SceneCollection"

type = Component.Type "SceneCollectionView"

type.modelType = SceneCollection.Kind

type.propTypes =
  style: Style

type.didMount ->
  @_view = this

type.willUnmount ->
  @_view = null

type.shouldUpdate ->
  return no

type.render (props) ->

  children = []
  for scene in @_scenes.array
    children.push @_elements[scene.__id] ?= scene._render { key: scene.__id }

  return View
    style: props.style
    children: children

module.exports = type.build()
