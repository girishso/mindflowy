###* @jsx React.DOM ###
$.ajaxSetup(
    contentType: 'application/json',
    dataType: 'json',
    type: 'POST',
    beforeSend: (xhr) ->
      token = $('meta[name="csrf-token"]').attr('content')
      if (token)
        xhr.setRequestHeader('X-CSRF-Token', token)


      atoken = $('meta[name="auth_token"]').attr('content')
      if (atoken)
        xhr.setRequestHeader('Authorization', 'Token token=' + atoken)
)

$(document).ajaxError ( event, jqxhr, settings, exception ) ->
  console.log exception
  alert(exception.message)


@ExampleComponent = React.createClass
  getInitialState: ->
    return {data: []}

  componentDidMount: ->
    that = this
    $.getJSON("/nodes", null, (d) ->
      console.log d
      that.setState data: d
    )


  render: ->
    `<div>
      <ul>
      {this.state.data.map(function(node) {
        return <TreeNode node={node} key={node.id} />
      })}
      </ul>
    </div>`


@TreeNode = React.createClass
  componentDidMount: ->
    domNode = this.getDOMNode()
    $(domNode).focus(->
      $this = $(this)
      $this.data('before', $this.html())
      return $this
    ).blur ->
      $this = $(this)
      if $this.data('before') isnt $this.html()
        $this.data('before', $this.html())
        id = $this.attr('data-id')
        fb.child(id).update
          title: $this.html()
      return $this

    if focus_node?
      if focus_node == this.props.node.id
        focus_node = null
        $(domNode).focus()

  render: ->
    if (this.props.node.children isnt null)
      childNodes = this.props.node.children.map (node) ->
        return `<TreeNode node={node} key={node.id} />`

    return (
      `<li>
      <div className="node" contentEditable onKeyDown={this.handleKeyDown}>
      {this.props.node.title}
      </div>
        <ul>
          {childNodes}
        </ul>
      </li>`
    )

