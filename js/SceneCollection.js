var Scene, SortedArray, Style, Type, View, assert, assertType, isType, ref, sync, type;

ref = require("modx"), Type = ref.Type, Style = ref.Style;

View = require("modx/views").View;

SortedArray = require("sorted-array");

assertType = require("assertType");

isType = require("isType");

assert = require("assert");

sync = require("sync");

Scene = require("./Scene");

type = Type("SceneCollection");

type.defineValues({
  _elements: function() {
    return {};
  },
  _scenes: function() {
    return SortedArray.comparing("level");
  }
});

type.defineGetters({
  scenes: function() {
    return this._scenes.array;
  },
  visibleScenes: function() {
    return this.scenes.filter(function(scene) {
      return !scene.isHidden;
    });
  },
  hiddenScenes: function() {
    return this.scenes.filter(function(scene) {
      return scene.isHidden;
    });
  }
});

type.defineMethods({
  insert: function(scene) {
    assertType(scene, Scene.Kind);
    assert(scene.collection === null, "Scenes can only belong to one collection at a time!");
    log.it(this.__name + ".insert: " + scene.__name);
    scene._collection = this;
    scene.__onInsert(this);
    this._scenes.insert(scene);
    this.view && this.view.forceUpdate();
  },
  remove: function(scene) {
    assertType(scene, Scene.Kind);
    assert(scene.collection === this, "Scene does not belong to this collection!");
    scene.__onRemove(this);
    scene._collection = null;
    this._scenes.remove(scene);
    delete this._elements[scene.__name];
    if (this.view) {
      this.view.forceUpdate();
    }
  },
  searchBelow: function(scene, filter) {
    var i, len, ref1, result, results;
    assertType(scene, Scene.Kind);
    assert(scene.collection === this, "Scene does not belong to this collection!");
    if (filter == null) {
      filter = emptyFunction.thatReturnsTrue;
    }
    results = [];
    ref1 = this._scenes.array;
    for (i = 0, len = ref1.length; i < len; i++) {
      result = ref1[i];
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

type.propTypes = {
  style: Style
};

type.shouldUpdate(function() {
  return false;
});

type.render(function() {
  var cache, children;
  cache = this._elements;
  children = sync.map(this._scenes.array, function(scene) {
    var key;
    key = scene.__name;
    if (cache[key]) {
      return cache[key];
    }
    return cache[key] = scene.render({
      key: key
    });
  });
  return View({
    style: this.props.style,
    children: children
  });
});

module.exports = type.build();

//# sourceMappingURL=map/SceneCollection.map
