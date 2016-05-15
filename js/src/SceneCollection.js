var Component, Scene, SortedArray, assertType, isType, type;

Component = require("component").Component;

SortedArray = require("sorted-array");

assertType = require("assertType");

isType = require("isType");

Scene = require("./Scene");

type = Component.Type("SceneCollection");

type.loadComponent(function() {
  return require("./SceneCollectionView");
});

type.defineProperties({
  scenes: {
    get: function() {
      return this._scenes.array;
    }
  },
  visibleScenes: {
    get: function() {
      return this.scenes.filter(function(s) {
        return !s.isHidden;
      });
    }
  },
  hiddenScenes: {
    get: function() {
      return this.scenes.filter(function(s) {
        return s.isHidden;
      });
    }
  }
});

type.defineValues({
  _view: null,
  _elements: function() {
    return {};
  },
  _scenes: function() {
    return SortedArray.comparing("level");
  }
});

type.defineMethods({
  insert: function(scene) {
    assertType(scene, Scene.Kind);
    assert(scene.collection === null, "Scenes can only belong to one collection at a time!");
    scene.collection = this;
    scene.__onInsert(this);
    this._scenes.insert(scene);
    if (this._view) {
      this._view.forceUpdate();
    }
  },
  remove: function(scene) {
    assertType(scene, Scene.Kind);
    assert(scene.collection === this, "Scene does not belong to this collection!");
    scene.__onRemove(this);
    scene.collection = null;
    this._scenes.remove(scene);
    delete this._elements[scene.__id];
    if (this._view) {
      this._view.forceUpdate();
    }
  },
  searchBelow: function(scene, filter) {
    var i, len, ref, result, results;
    assertType(scene, Scene.Kind);
    assert(scene.collection === this, "Scene does not belong to this collection!");
    if (filter == null) {
      filter = emptyFunction.thatReturnsTrue;
    }
    results = [];
    ref = this._scenes.array;
    for (i = 0, len = ref.length; i < len; i++) {
      result = ref[i];
      if (result === scene) {
        return;
      }
      if (!filter(result)) {
        continue;
      }
      results.push(result);
    }
    return results;
  }
});

module.exports = type.build();

//# sourceMappingURL=../../map/src/SceneCollection.map
