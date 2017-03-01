
# TODO: Support 'scene.router' for nested routing (like tab bars).
# TODO: Events for changes.
# TODO: Add method for getting serialized data from any specific scene.

assertType = require "assertType"
isType = require "isType"
Event = require "eve"
modx = require "modx"

Scene = require "./Scene"

type = modx.Type "SceneRouter"

type.defineArgs
  events: Event.Map

type.defineValues (options) ->
  return options

type.defineGetters

  root: -> @_root

  path: ->
    if @_root
    then @_chains[@_root].path
    else null

  chain: ->
    if @_root
    then @_chains[@_root]
    else null

type.render ->
  props = Object.assign {}, @props
  @_scenes.render props

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

  # Get a root scene by its path.
  # Returns a scene factory if its path is provided.
  get: (path) -> @_routes[path]

  # Set the current root scene (and mount if needed).
  set: (path, options) ->
    assertType path, String
    return if path is @_root

    if @_root isnt null
      scene = @_routes[@_root]
      scene.__onInactive()

    scene = @_load path, options
    @_startChain scene, path

    @_root = path
    scene.__onActive()
    return scene

  # Mount a root scene, but don't set it as current.
  insert: (path, options) ->
    assertType path, String
    scene = @_load path, options
    @_startChain scene, path
    return scene

  # Unmounts a root scene, or unloads a scene factory.
  remove: (path) ->

    if path is @_root
      @_root = null

    scene = @_routes[path]
    return if scene is undefined

    if scene instanceof Scene
      @_scenes.remove scene
      # TODO: Remove every scene in the root chain.

    delete @_routes[path]
    return

  # Push a scene onto the current root's scene chain.
  push: (path, options) ->
    assertType path, String
    assertType options, Object.or Scene.Kind

    scene =
      if isType options, Object
      then @_load path, options
      else options

    @chain.push scene, path
    return

  reset: ->
    Object.assign this, getInitialValue()
    @view.forceUpdate()
    return

#
# Internals
#

type.defineValues getInitialValue = ->

  _root: null

  _scenes: Scene.Collection()

  # The router manages a stack of scenes for every root path.
  _chains: Object.create null

  # The map of `Scene` instances and/or factories.
  _routes: Object.create null

  # The map of "route loaders".
  _loaders: Object.create null

type.defineMethods

  # If the `path` points to a scene factory, the `options` are used to construct an instance.
  # If the `path` points to a `Scene` instance, the `options` are ignored.
  # The `options` can be a `Scene` instance if you want to add a root scene.
  # Otherwise, some route is lazy-loaded by its `path`.
  _load: (path, options) ->
    scene = @_routes[path]

    if options instanceof Scene

      if typeof scene is "function"
        throw Error "Cannot overwrite a scene factory: '#{path}'"

      if scene isnt undefined
        throw Error "A root scene already exists with path: '#{path}'"

      @_routes[path] = scene = options

    else if scene is undefined

      unless loader = @_loaders[path]
        throw Error "Invalid path: '#{path}'"

      @_routes[path] = scene = loader()

    if typeof scene is "function"
      scene = scene options

    else if options isnt undefined
      throw Error "The 'options' argument is only for scene factories!"

    @_scenes.insert scene
    return scene

  _startChain: (scene, path) ->
    unless @_chains[path]
      chain = Scene.Chain()
      chain.push scene, path
      @_chains[path] = chain
    return

module.exports = type.build()
