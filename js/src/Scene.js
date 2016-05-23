var Children, Component, Style, View, emptyFunction, getArgProp, ref, throwFailure, type;

require("isDev");

ref = require("component"), Component = ref.Component, Style = ref.Style, Children = ref.Children, View = ref.View;

throwFailure = require("failure").throwFailure;

emptyFunction = require("emptyFunction");

getArgProp = require("getArgProp");

type = Component.Type("Scene");

type.optionTypes = {
  level: Number,
  isHidden: Boolean,
  ignoreTouches: Boolean,
  ignoreTouchesBelow: Boolean
};

type.optionDefaults = {
  level: 0,
  isHidden: true,
  ignoreTouches: false,
  ignoreTouchesBelow: false
};

if (isDev) {
  global.scenes = Object.create(null);
  type.initInstance(function() {
    return global.scenes[this.__id] = this;
  });
}

type.defineReactiveValues({
  _level: getArgProp("level"),
  isHidden: getArgProp("isHidden"),
  ignoreTouches: getArgProp("ignoreTouches"),
  ignoreTouchesBelow: getArgProp("ignoreTouchesBelow")
});

type.defineValues({
  _chain: null,
  _collection: null
});

type.exposeGetters(["chain", "collection"]);

type.defineProperties({
  level: {
    get: function() {
      return this._level;
    },
    set: function() {}
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
  __renderContent: function() {
    return View({
      children: this.props.children,
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

//# sourceMappingURL=../../map/src/Scene.map
