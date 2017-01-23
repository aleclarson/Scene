
# Scene

The `Scene` class is a `Component.Type` that is used by
`SceneChain` and `SceneCollection` as a visual unit that
can be focused and/or sorted.

```coffee
Scene = require "Scene"
```

#### Option Types

```coffee
# The number used for ordering by a 'Scene.Collection'.
# Defaults to zero.
level: Number

# Should this layer be hidden?
# Defaults to true.
isHidden: Boolean

# Should this layer ignore touches?
# Defaults to false.
ignoreTouches: Boolean

# Should this layer block touches to any layers beneath it?
# Defaults to false.
ignoreTouchesBelow: Boolean
```

#### Properties

```coffee
# Equals true when focused by its current 'Scene.Chain'.
scene.isActive

# A reactive Number.
# Defaults to 'options.level'.
scene.level

# A reactive Boolean.
# Defaults to 'options.isHidden'.
scene.isHidden

# A reactive Boolean.
# Defaults to 'options.ignoreTouches'.
scene.ignoreTouches

# A reactive Boolean.
# Defaults to 'options.ignoreTouchesBelow'.
scene.ignoreTouchesBelow
```

#### Styles

```coffee
# The style of the root view.
styles.container

# The style of the content view.
styles.content

# The style of the background view.
styles.background
```

#### Prototype

The methods below are recommended for overriding with subclasses:

```coffee
# Called when rendering the children of the content view.
scene.__renderChildren()

# Called when this scene is inserted into a 'Scene.Collection'.
scene.__onInsert(sceneCollection)

# Called when this scene is removed from its 'Scene.Collection'.
scene.__onRemove(sceneCollection)

# Called when this scene becomes the last scene in its 'Scene.Chain'.
scene.__onActive(sceneChain)

# Called when this scene is popped from its 'Scene.Chain'.
scene.__onInactive(sceneChain)
```
