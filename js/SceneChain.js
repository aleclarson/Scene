var Scene, Type, assert, assertType, type;

assertType = require("assertType");

assert = require("assert");

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
    scene._chain = this;
    scene.__onActive(this);
    this.scenes.push(scene);
    this.last = scene;
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
