###* @jsx React.DOM ###

ExampleComponent = React.createClass
  render: ->
    `<div> {this.props.name} </div>`

window.ExampleComponent = ExampleComponent
