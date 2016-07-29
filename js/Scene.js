var Children, Component, Style, View, emptyFunction, fromArgs, ref, type;

require("isDev");

ref = require("component"), Component = ref.Component, Style = ref.Style, Children = ref.Children, View = ref.View;

emptyFunction = require("emptyFunction");

fromArgs = require("fromArgs");

type = Component.Type("Scene");

type.defineOptions({
  level: Number.withDefault(0),
  isHidden: Boolean.withDefault(true),
  ignoreTouches: Boolean.withDefault(false),
  ignoreTouchesBelow: Boolean.withDefault(false)
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
  _level: fromArgs("level"),
  _chain: null,
  _collection: null
});

type.defineGetters({
  chain: function() {
    return this._chain;
  },
  collection: function() {
    return this._collection;
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

type.propTypes = {
  style: Style,
  children: Children
};

type.defineNativeValues({
  scale: 1,
  opacity: function() {
    return (function(_this) {
      return function() {
        if (_this._chain && _this._chain.isHidden) {
          return 0;
        }
        if (_this.isHidden) {
          return 0;
        }
        return 1;
      };
    })(this);
  },
  containerEvents: function() {
    return (function(_this) {
      return function() {
        if (_this._chain && _this._chain.isHidden) {
          return "none";
        }
        if (_this.isHidden) {
          return "none";
        }
        return "box-none";
      };
    })(this);
  },
  contentEvents: function() {
    return (function(_this) {
      return function() {
        if (_this.isTouchable) {
          return "box-none";
        }
        return "none";
      };
    })(this);
  },
  backgroundEvents: function() {
    return (function(_this) {
      return function() {
        if (_this.isTouchableBelow) {
          return "none";
        }
        return "auto";
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
