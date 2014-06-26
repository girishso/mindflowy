###* @jsx React.DOM ###

@ExampleComponent = React.createClass
  componentDidMount: ->
    data = null
    $.getJSON("/users/2/nodes", null, (d) ->
      data = d
    )
  render: ->
    `<div> 
      {this.props.name}
      <TreeView nodeLabel="aa" >
        <TreeView nodeLabel="AA" />
        <TreeView nodeLabel="BB" />
      </TreeView>
    </div>`

