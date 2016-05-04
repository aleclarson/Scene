var Scene, Type, assert, assertType, ref, type;

ref = require("type-utils"), assert = ref.assert, assertType = ref.assertType;

Type = require("Type");

Scene = require("./Scene");

type = Type("SceneChain");

type.defineValues({
  scenes: function() {
    return [];
  }
});

type.defineReactiveValues({
  last: null
});

type.defineMethods({
  push: function(scene) {
    assertType(scene, Scene.Kind);
    assert(scene.chain === null, "Scenes can only belong to one chain at a time!");
    if (this.last) {
      this.last.__onInactive(this);
    }
    scene.chain = this;
    scene.__onActive(this);
    this.scenes.push(scene);
    this.last = scene;
  },
  pop: function() {
    var length;
    length = this.scenes.length;
    if (length === 0) {
      return;
    }
    this.scenes.pop().__onInactive(this);
    if (length === 1) {
      this.last = null;
      return;
    }
    this.last = this.scenes[length - 2];
    this.last.__onActive(this);
  }
});

module.exports = type.build();

//# sourceMappingURL=../../map/src/SceneChain.map
