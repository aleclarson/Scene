var Component, Scene, SortedArray, Style, View, assert, assertType, isType, ref, type;

ref = require("component"), Component = ref.Component, Style = ref.Style, View = ref.View;

SortedArray = require("sorted-array");

assertType = require("assertType");

isType = require("isType");

assert = require("assert");

Scene = require("./Scene");

type = Component.Type("SceneCollection");

type.defineProperties({
  scenes: {
    get: function() {
      return this._scenes.array;
    }
  },
  visibleScenes: {
    get: function() {
      return this.scenes.filter(function(scene) {
        return !scene.isHidden;
      });
    }
  },
  hiddenScenes: {
    get: function() {
      return this.scenes.filter(function(scene) {
        return scene.isHidden;
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
    scene._collection = this;
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
    scene._collection = null;
    this._scenes.remove(scene);
    delete this._elements[scene.__id];
    if (this._view) {
      this._view.forceUpdate();
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

type.render(function(props) {
  var base, children, i, len, name, ref1, scene;
  children = [];
  ref1 = this._scenes.array;
  for (i = 0, len = ref1.length; i < len; i++) {
    scene = ref1[i];
    children.push((base = this._elements)[name = scene.__name] != null ? base[name] : base[name] = scene._render({
      key: scene.__name
    }));
  }
  return View({
    style: props.style,
    children: children
  });
});

module.exports = type.build();

//# sourceMappingURL=../../map/src/SceneCollection.map
