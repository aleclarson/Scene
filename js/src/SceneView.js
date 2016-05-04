var Children, Component, Scene, Style, View, emptyFunction, ref, type;

ref = require("component"), Style = ref.Style, Children = ref.Children, Component = ref.Component, View = ref.View;

emptyFunction = require("emptyFunction");

Scene = require("./Scene");

type = Component();

type.contextType = Scene;

type.propTypes = {
  style: Style,
  children: Children
};

type.defineProperties({
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
        if (_this.view.isTouchable) {
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
        if (_this.view.isTouchableBelow) {
          return "none";
        } else {
          return "auto";
        }
      };
    })(this);
  }
});

type.render(function(props) {
  var background, content;
  background = View({
    style: this.styles.background,
    pointerEvents: this.view.backgroundEvents,
    onStartShouldSetResponder: emptyFunction.thatReturnsTrue
  });
  content = View({
    style: [this.styles.content, props.style],
    children: props.children,
    pointerEvents: this.view.contentEvents
  });
  return View({
    style: this.styles.container,
    children: [background, content],
    pointerEvents: this.view.containerEvents
  });
});

module.exports = type.build();

//# sourceMappingURL=../../map/src/SceneView.map
