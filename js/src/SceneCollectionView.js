var Component, SceneCollection, Style, View, ref, type;

ref = require("component"), Component = ref.Component, Style = ref.Style, View = ref.View;

SceneCollection = require("./SceneCollection");

type = Component.Type("SceneCollectionView");

type.modelType = SceneCollection.Kind;

type.propTypes = {
  style: Style
};

type.didMount(function() {
  return this._view = this;
});

type.willUnmount(function() {
  return this._view = null;
});

type.shouldUpdate(function() {
  return false;
});

type.render(function(props) {
  var base, children, i, len, name, ref1, scene;
  children = [];
  ref1 = this._scenes.array;
  for (i = 0, len = ref1.length; i < len; i++) {
    scene = ref1[i];
    children.push((base = this._elements)[name = scene.__id] != null ? base[name] : base[name] = scene._render({
      key: scene.__id
    }));
  }
  return View({
    style: props.style,
    children: children
  });
});

module.exports = type.build();

//# sourceMappingURL=../../map/src/SceneCollectionView.map
