define(
  ["./react-es6","./react-es6/lib/ReactTransitionEvents","exports"],
  function(__dependency1__, __dependency2__, __exports__) {
    "use strict";
    var React = __dependency1__["default"];
    var ReactTransitionEvents = __dependency2__["default"];

    var CollapsableMixin = {

      propTypes: {
        collapsable: React.PropTypes.bool,
        defaultExpanded: React.PropTypes.bool,
        expanded: React.PropTypes.bool
      },

      getInitialState: function () {
        return {
          expanded: this.props.defaultExpanded != null ? this.props.defaultExpanded : null,
          collapsing: false
        };
      },

      handleTransitionEnd: function () {
        this._collapseEnd = true;
        this.setState({
          collapsing: false
        });
      },

      componentWillReceiveProps: function (newProps) {
        if (this.props.collapsable && newProps.expanded !== this.props.expanded) {
          this._collapseEnd = false;
          this.setState({
            collapsing: true
          });
        }
      },

      _addEndTransitionListener: function () {
        var node = this.getCollapsableDOMNode();

        if (node) {
          ReactTransitionEvents.addEndEventListener(
            node,
            this.handleTransitionEnd
          );
        }
      },

      _removeEndTransitionListener: function () {
        var node = this.getCollapsableDOMNode();

        if (node) {
          ReactTransitionEvents.addEndEventListener(
            node,
            this.handleTransitionEnd
          );
        }
      },

      componentDidMount: function () {
        this._afterRender();
      },

      componentWillUnmount: function () {
        this._removeEndTransitionListener();
      },

      componentWillUpdate: function (nextProps) {
        var dimension = (typeof this.getCollapsableDimension === 'function') ?
          this.getCollapsableDimension() : 'height';
        var node = this.getCollapsableDOMNode();

        this._removeEndTransitionListener();
        if (node && nextProps.expanded !== this.props.expanded && this.props.expanded) {
          node.style[dimension] = this.getCollapsableDimensionValue() + 'px';
        }
      },

      componentDidUpdate: function (prevProps, prevState) {
        if (this.state.collapsing !== prevState.collapsing) {
          this._afterRender();
        }
      },

      _afterRender: function () {
        if (!this.props.collapsable) {
          return;
        }

        this._addEndTransitionListener();
        setTimeout(this._updateDimensionAfterRender, 0);
      },

      _updateDimensionAfterRender: function () {
        var dimension = (typeof this.getCollapsableDimension === 'function') ?
          this.getCollapsableDimension() : 'height';
        var node = this.getCollapsableDOMNode();

        if (node) {
          node.style[dimension] = this.isExpanded() ?
            this.getCollapsableDimensionValue() + 'px' : '0px';
        }
      },

      isExpanded: function () {
        return (this.props.expanded != null) ?
          this.props.expanded : this.state.expanded;
      },

      getCollapsableClassSet: function (className) {
        var classes = {};

        if (typeof className === 'string') {
          className.split(' ').forEach(function (className) {
            if (className) {
              classes[className] = true;
            }
          });
        }

        classes.collapsing = this.state.collapsing;
        classes.collapse = !this.state.collapsing;
        classes['in'] = this.isExpanded() && !this.state.collapsing;

        return classes;
      }
    };

    __exports__["default"] = CollapsableMixin;
  });