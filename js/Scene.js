// Generated by CoffeeScript 1.12.4
var Children, Event, ReactUpdateQueue, Scene, SceneTree, Style, View, containerStyle, emptyFunction, modx, ref, type;

ref = require("react-validators"), Style = ref.Style, Children = ref.Children;

ReactUpdateQueue = require("react-native/lib/ReactUpdateQueue");

emptyFunction = require("emptyFunction");

Event = require("eve");

View = require("modx/lib/View");

modx = require("modx");

SceneTree = require("./SceneTree");

type = modx.Type("Scene");

type.defineArgs({
  level: Number,
  isHidden: Boolean,
  isPermanent: Boolean,
  ignoreTouches: Boolean,
  ignoreTouchesBelow: Boolean
});

type.defineValues(function() {
  return {
    path: null,
    didMount: Event()
  };
});

type.defineReactiveValues(function(options) {
  var ref1;
  return {
    isHidden: options.isHidden === true,
    isPermanent: options.isPermanent === true,
    ignoreTouches: options.ignoreTouches === true,
    ignoreTouchesBelow: options.ignoreTouchesBelow === true,
    _level: (ref1 = options.level) != null ? ref1 : 0,
    _chain: null,
    _collection: null
  };
});

type.defineReactions({
  _containerOpacity: function() {
    if (this._chain && this._chain.isHidden) {
      return 0;
    }
    if (this.isHidden) {
      return 0;
    }
    return 1;
  },
  _containerEvents: function() {
    if (this._chain && this._chain.isHidden) {
      return "none";
    }
    if (this.isHidden) {
      return "none";
    }
    return "box-none";
  },
  _foregroundEvents: function() {
    if (this.isTouchable) {
      return "box-none";
    }
    return "none";
  },
  _backgroundEvents: function() {
    if (this.isTouchableBelow) {
      return "none";
    }
    return "auto";
  }
});

type.defineGetters({
  chain: function() {
    return this._chain;
  },
  collection: function() {
    return this._collection;
  },
  isActive: function() {
    return this._chain && this._chain.current === this;
  },
  isTouchable: function() {
    return !this.ignoreTouches;
  },
  isTouchableBelow: function() {
    return this.ignoreTouches || !this.ignoreTouchesBelow;
  }
});

type.definePrototype({
  level: {
    get: function() {
      return this._level;
    },
    set: function(newValue) {
      if (this.view) {
        throw Error("Cannot set scene level while mounted!");
      }
      return this._level = newValue;
    }
  }
});

type.defineMethods({
  onceMounted: function(callback) {
    if (this.view && ReactUpdateQueue.isMounted(this.view)) {
      return callback();
    } else {
      return this.didMount.once(callback);
    }
  }
});

type.defineHooks({
  __onInsert: emptyFunction,
  __onActive: emptyFunction,
  __onInactive: emptyFunction,
  __onRemove: emptyFunction
});

type.defineStatics({
  find: function(view) {
    return SceneTree.findScene(view);
  }
});

type.defineProps({
  style: Style,
  children: Children
});

type.didMount(function() {
  SceneTree._addScene(this);
  this.didMount.emit();
});

type.shouldUpdate(function() {
  return false;
});

type.willUnmount(function() {
  SceneTree._removeScene(this);
});

type.render(function() {
  var background, foreground;
  background = View({
    style: containerStyle,
    pointerEvents: this._backgroundEvents,
    onStartShouldSetResponder: emptyFunction.thatReturnsTrue,
    children: this.__renderBackground()
  });
  foreground = View({
    style: containerStyle,
    pointerEvents: this._foregroundEvents,
    children: this.__renderForeground()
  });
  return View({
    pointerEvents: this._containerEvents,
    style: [
      containerStyle, {
        opacity: this._containerOpacity
      }
    ],
    children: [background, foreground]
  });
});

type.defineHooks({
  __renderForeground: function() {
    return this.props.children;
  },
  __renderBackground: emptyFunction
});

module.exports = Scene = type.build();

containerStyle = {
  position: "absolute",
  top: 0,
  left: 0,
  right: 0,
  bottom: 0,
  backgroundColor: "transparent"
};