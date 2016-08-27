var Scene, SortedArray, Style, Type, View, assertType, isType, ref, sync, type;

ref = require("modx"), Type = ref.Type, Style = ref.Style;

View = require("modx/views").View;

SortedArray = require("sorted-array");

assertType = require("assertType");

isType = require("isType");

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
    if (scene.collection === this) {
      return;
    }
    if (scene.collection !== null) {
      throw Error("Scenes can only belong to one collection at a time!");
    }
    scene._collection = this;
    scene.__onInsert(this);
    this._scenes.insert(scene);
    this.view && this.view.forceUpdate();
  },
  remove: function(scene) {
    var index;
    assertType(scene, Scene.Kind);
    if (scene.collection !== this) {
      throw Error("Scene does not belong to this collection!");
    }
    scene.__onRemove(this);
    scene._collection = null;
    index = this._scenes.array.indexOf(scene);
    this._scenes.array.splice(index, 1);
    delete this._elements[scene.__name];
    this.view && this.view.forceUpdate();
  },
  searchBelow: function(scene, filter) {
    var i, len, ref1, result, results;
    assertType(scene, Scene.Kind);
    if (scene.collection !== this) {
      throw Error("Scene does not belong to this collection!");
    }
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

type.defineProps({
  style: Style
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

type.shouldUpdate(function() {
  return false;
});

module.exports = type.build();

//# sourceMappingURL=map/SceneCollection.map
