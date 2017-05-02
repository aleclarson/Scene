
# TODO: Support 'scene.router' for nested routing (like tab bars).
# TODO: Events for changes.
# TODO: Add method for getting serialized data from any specific scene.

assertType = require "assertType"
isType = require "isType"
modx = require "modx"
has = require "has"

SceneCollection = require "./SceneCollection"
SceneChain = require "./SceneChain"
Scene = require "./Scene"

type = modx.Type "SceneRouter"

type.defineGetters

  root: -> @_root

  path: ->
    if scene = @current
    then scene.path
    else null

  current: ->
    if @_root
    then @_chains[@_root].current
    else null

  chain: ->
    if @_root
    then @_chains[@_root]
    else null

type.defineMethods

  # Add a root scene loader with a unique path.
  addLoader: (path, loader) ->
    assertType path, String
    assertType loader, Function

    if @_loaders[path] isnt undefined
      throw Error "Cannot add same path twice: '#{path}'"

    @_loaders[path] = loader
    return

  addLoaders: (loaders) ->
    assertType loaders, Object
    for path, loader of loaders
      @addLoader path, loader
    return

  get: (path) ->
    if isType path, Number
    then @_scenes.array[path]
    else @_routes[path]

  set: (path, options) ->
    assertType path, String

    if path is @_root
      return @_routes[path]

    if @_root isnt null
      scene = @_chains[@_root].current
      scene.__onInactive()

    scene = @_load path, options

    unless isType options, Object.Maybe
      options = undefined

    @_root = scene.path
    @_markActive scene, options
    return scene

  insert: (path, options) ->
    assertType path, String
    return @_load path, options

  push: (path, options) ->
    assertType path, String

    unless @_root
      throw Error "Cannot call 'push' before 'set'!"

    scene = @_load path, options

    unless isType options, Object.Maybe
      options = undefined

    @_chains[@_root].push scene, options
    return scene

  pop: ->
    return null unless @_root
    scene = @_chains[@_root].pop()

    if scene.path is @_root
      delete @_chains[@_root]
      @_root = null

    unless scene.isPermanent
      @_scenes.remove scene
      delete @_routes[scene.path]

    return scene

  remove: (path) ->
    assertType path, String

    unless scene = @_routes[path]
      return null

    if path is @_root
      @_root = null

    unless chain = scene.chain
      return scene

    while chain.length
      current = chain.pop()

      unless current.isPermanent
        @_scenes.remove current
        delete @_routes[current.path]

      break if scene is current

    unless chain.length
      delete @_chains[path]

    return scene

  reset: ->
    Object.assign this, getInitialValue()
    @view.forceUpdate()
    return

#
# Rendering
#

type.render ->
  props = Object.assign {}, @props
  props.style ?= @styles.container()
  return @_scenes.render props

type.defineStyles

  container:
    cover: yes
    backgroundColor: "#000"

#
# Internal
#

type.defineValues getInitialValue = ->

  _root: null

  _scenes: SceneCollection()

  # The router manages a stack of scenes for every root path.
  _chains: Object.create null

  # The map of `Scene` instances.
  _routes: Object.create null

  # The map of `Scene` loaders.
  _loaders: Object.create null

type.defineMethods

  _load: (path, options) ->

    if isType options, Object.Maybe

      # Check if the scene is already loaded.
      return scene if scene = @_routes[path]

      unless loader = @_loaders[path]
        throw Error "Failed to load scene: '#{path}'"

      # Load the scene on-demand.
      scene = loader()

      # Loaders may return a scene factory.
      if typeof scene is "function"
        scene = scene options

    else if has @_loaders, path
      throw Error "Cannot overwrite a scene loader: '#{path}'"

    else if has @_routes, path
      throw Error "Cannot overwrite an existing scene: '#{path}'"

    # They passed a `Scene` instance.
    else scene = options

    unless scene instanceof Scene
      throw Error "Expected a kind of Scene!"

    # Ensure the scene has a path.
    scene.path ?= path

    @_routes[scene.path] = scene
    @_scenes.insert scene
    return scene

  _markActive: (scene, options) ->

    if scene.chain
      scene.__onActive options
      return

    chain = SceneChain()
    chain.push scene, options
    @_chains[scene.path] = chain
    return

module.exports = type.build()
