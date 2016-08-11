var Scene, SceneCollection, Type, assert, assertType, fromArgs, sync, type;

assertType = require("assertType");

fromArgs = require("fromArgs");

assert = require("assert");

Type = require("Type");

sync = require("sync");

SceneCollection = require("./SceneCollection");

Scene = require("./Scene");

type = Type("SceneChain");

type.defineOptions({
  isHidden: Boolean.withDefault(false),
  collection: SceneCollection
});

type.defineValues({
  scenes: function() {
    return [];
  },
  _collection: fromArgs("collection")
});

type.defineReactiveValues({
  isHidden: fromArgs("isHidden"),
  last: null
});

type.definePrototype({
  collection: {
    get: function() {
      return this._collection;
    },
    set: function(newValue, oldValue) {
      this._collection = newValue;
      if (newValue) {
        if (oldValue) {
          sync.each(this.scenes, function(scene) {
            oldValue.remove(scene);
            return newValue.insert(scene);
          });
        } else {
          sync.each(this.scenes, function(scene) {
            return newValue.insert(scene);
          });
        }
      } else if (oldValue) {
        sync.each(this.scenes, function(scene) {
          return oldValue.remove(scene);
        });
      }
    }
  }
});

type.defineMethods({
  push: function(scene) {
    assertType(scene, Scene.Kind);
    assert(scene.chain === null, "Scenes can only belong to one chain at a time!");
    this.last && this.last.__onInactive(this);
    scene._chain = this;
    scene.__onActive(this);
    this.scenes.push(scene);
    this.last = scene;
    this._collection && this._collection.insert(scene);
  },
  pop: function() {
    var length, scene;
    length = this.scenes.length;
    if (length === 0) {
      return;
    }
    scene = this.scenes.pop();
    scene.__onInactive(this);
    scene._chain = null;
    if (!scene.isPermanent) {
      this._collection && this._collection.remove(scene);
    }
    if (length === 1) {
      this.last = null;
      return;
    }
    this.last = this.scenes[length - 2];
    this.last.__onActive(this);
  }
});

module.exports = type.build();

//# sourceMappingURL=map/SceneChain.map
