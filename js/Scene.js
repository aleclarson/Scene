var Children, Component, Style, View, emptyFunction, fromArgs, ref, type;

require("isDev");

ref = require("component"), Component = ref.Component, Style = ref.Style, Children = ref.Children, View = ref.View;

emptyFunction = require("emptyFunction");

fromArgs = require("fromArgs");

type = Component.Type("Scene");

type.defineOptions({
  level: {
    type: Number,
    "default": 0
  },
  isHidden: {
    type: Boolean,
    "default": true
  },
  ignoreTouches: {
    type: Boolean,
    "default": false
  },
  ignoreTouchesBelow: {
    type: Boolean,
    "default": false
  }
});

if (isDev) {
  global.scenes = Object.create(null);
  type.initInstance(function() {
    return global.scenes[this.__name] = this;
  });
}

type.defineReactiveValues({
  isHidden: fromArgs("isHidden"),
  ignoreTouches: fromArgs("ignoreTouches"),
  ignoreTouchesBelow: fromArgs("ignoreTouchesBelow"),
  _level: fromArgs("level")
});

type.defineValues({
  _chain: null,
  _collection: null
});

type.exposeGetters(["chain", "collection"]);

type.definePrototype({
  level: {
    get: function() {
      return this._level;
    },
    set: function() {
      throw Error("Unimplemented!");
    }
  },
  isActive: {
    get: function() {
      if (!this._chain) {
        return false;
      }
      return this === this._chain.last;
    }
  },
  isTouchable: {
    get: function() {
      if (this.ignoreTouches) {
        return false;
      }
      return true;
    }
  },
  isTouchableBelow: {
    get: function() {
      if (this.ignoreTouchesBelow) {
        return false;
      }
      if (this.ignoreTouches) {
        return true;
      }
      return true;
    }
  }
});

type.defineMethods({
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

type.propTypes = {
  style: Style,
  children: Children
};

type.defineNativeValues({
  scale: 1,
  opacity: function() {
    return (function(_this) {
      return function() {
        if (_this.isHidden) {
          return 0;
        } else {
          return 1;
        }
      };
    })(this);
  },
  containerEvents: function() {
    return (function(_this) {
      return function() {
        if (_this.isHidden) {
          return "none";
        } else {
          return "box-none";
        }
      };
    })(this);
  },
  contentEvents: function() {
    return (function(_this) {
      return function() {
        if (_this.isTouchable) {
          return "box-none";
        } else {
          return "none";
        }
      };
    })(this);
  },
  backgroundEvents: function() {
    return (function(_this) {
      return function() {
        if (_this.isTouchableBelow) {
          return "none";
        } else {
          return "auto";
        }
      };
    })(this);
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

type.defineMethods({
  __renderChildren: function() {
    return this.props.children;
  },
  __renderContent: function() {
    return View({
      children: this.__renderChildren(),
      pointerEvents: this.contentEvents,
      style: [this.styles.content(), this.props.style]
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
