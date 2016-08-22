var Children, Style, Type, View, emptyFunction, ref, type;

require("isDev");

ref = require("modx"), Type = ref.Type, Style = ref.Style, Children = ref.Children;

View = require("modx/views").View;

emptyFunction = require("emptyFunction");

type = Type("Scene");

type.defineOptions({
  level: Number.withDefault(0),
  isHidden: Boolean.withDefault(false),
  isPermanent: Boolean.withDefault(false),
  ignoreTouches: Boolean.withDefault(false),
  ignoreTouchesBelow: Boolean.withDefault(false)
});

if (isDev) {
  global.scenes = Object.create(null);
  type.initInstance(function() {
    return global.scenes[this.__name] = this;
  });
}

type.defineReactiveValues(function(options) {
  return {
    isHidden: options.isHidden,
    isPermanent: options.isPermanent,
    ignoreTouches: options.ignoreTouches,
    ignoreTouchesBelow: options.ignoreTouchesBelow,
    _level: options.level,
    _chain: null,
    _collection: null
  };
});

type.defineGetters({
  chain: function() {
    return this._chain;
  },
  isTouchable: function() {
    if (this.ignoreTouches) {
      return false;
    }
    return true;
  },
  isTouchableBelow: function() {
    if (this.ignoreTouchesBelow) {
      return false;
    }
    if (this.ignoreTouches) {
      return true;
    }
    return true;
  }
});

type.definePrototype({
  collection: {
    get: function() {
      return this._collection;
    },
    set: function(newValue) {
      if (newValue === null) {
        return this._collection.remove(this);
      } else {
        return newValue.insert(this);
      }
    }
  },
  level: {
    get: function() {
      return this._level;
    },
    set: function() {
      throw Error("Unimplemented!");
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
  Chain: {
    lazy: function() {
      return require("./SceneChain");
    }
  },
  Collection: {
    lazy: function() {
      return require("./SceneCollection");
    }
  }
});

type.defineProps({
  style: Style,
  children: Children
});

type.defineNativeValues({
  scale: 1,
  opacity: function() {
    if (this._chain && this._chain.isHidden) {
      return 0;
    }
    if (this.isHidden) {
      return 0;
    }
    return 1;
  },
  containerEvents: function() {
    if (this._chain && this._chain.isHidden) {
      return "none";
    }
    if (this.isHidden) {
      return "none";
    }
    return "box-none";
  },
  contentEvents: function() {
    if (this.isTouchable) {
      return "box-none";
    }
    return "none";
  },
  backgroundEvents: function() {
    if (this.isTouchableBelow) {
      return "none";
    }
    return "auto";
  }
});

type.defineStyles({
  container: {
    cover: true,
    clear: true,
    opacity: function() {
      return this.opacity;
    }
  },
  background: {
    cover: true,
    clear: true
  },
  content: {
    cover: true,
    clear: true,
    scale: function() {
      return this.scale;
    }
  }
});

type.render(function() {
  return View({
    style: this.styles.container(),
    pointerEvents: this.containerEvents,
    children: [this.__renderBackground(), this.__renderContent()]
  });
});

type.defineHooks({
  __renderChildren: function() {
    return this.props.children;
  },
  __renderContent: function() {
    return View({
      style: this.styles.content(),
      pointerEvents: this.contentEvents,
      children: this.__renderChildren()
    });
  },
  __renderBackground: function() {
    return View({
      style: this.styles.background(),
      pointerEvents: this.backgroundEvents,
      onStartShouldSetResponder: emptyFunction.thatReturnsTrue
    });
  }
});

module.exports = type.build();

//# sourceMappingURL=map/Scene.map
