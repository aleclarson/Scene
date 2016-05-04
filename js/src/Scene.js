var Component, emptyFunction, throwFailure, type;

require("isDev");

throwFailure = require("failure").throwFailure;

Component = require("component").Component;

emptyFunction = require("emptyFunction");

type = Component.Type("Scene");

type.loadComponent(function() {
  return require("./SceneView");
});

type.defineStatics({
  Chain: {
    lazy: function() {
      return require("./Chain");
    }
  },
  Collection: {
    lazy: function() {
      return require("./Collection");
    }
  }
});

if (isDev) {
  global.scenes = Object.create(null);
  type.initInstance(function() {
    return global.scenes[this.__id] = this;
  });
}

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

type.defineReactiveValues({
  _level: function(options) {
    return options.level;
  },
  isHidden: function(options) {
    return options.isHidden;
  },
  ignoreTouches: function(options) {
    return options.ignoreTouches;
  },
  ignoreTouchesBelow: function(options) {
    return options.ignoreTouchesBelow;
  }
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
  }
});

type.defineMethods({
  __onInsert: emptyFunction,
  __onActive: emptyFunction,
  __onInactive: emptyFunction,
  __onRemove: emptyFunction
});

type.defineStyles({
  container: {
    presets: ["cover", "clear"],
    opacity: function() {
      return this.view.opacity;
    }
  },
  background: {
    presets: ["cover", "clear"]
  },
  content: {
    presets: ["cover", "clear"],
    scale: function() {
      return this.view.scale;
    }
  }
});

module.exports = type.build();

//# sourceMappingURL=../../map/src/Scene.map
