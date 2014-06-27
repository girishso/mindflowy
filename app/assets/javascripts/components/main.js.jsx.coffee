###* @jsx React.DOM ###

focus_node = null

@ExampleComponent = React.createClass
  getInitialState: ->
    return {data: []}

  componentDidMount: ->
    that = this
    $.getJSON("/nodes", null, (d) ->
      console.log d
      that.setState data: d
    )

    $(".treeview").on "focus", ".editable", ->
      $this = $(this)
      $this.data('before', $this.html())
      return $this

    $(".treeview").on "blur", ".editable", ->
      $this = $(this)
      if $this.data('before') isnt $this.html()
        $this.data('before', $this.html())
        node_id = $this.attr('data-id')
        $.ajax
          type: "PUT"
          url: "/nodes/#{node_id}"
          data:
            node:
              title: $this.html()
      return $this


  componentDidUpdate: ->
    console.log "componentDidUpdate", focus_node
    if focus_node?
      $(".editable[data-id='#{focus_node}']").focus()
      focus_node = null

  handleKeyDown: (e) ->
    console.log e.which, e.target
    $target = $(e.target)
    node_id = $target.attr("data-id")
    $component = this

    if e.which == 38 # up
      e.preventDefault()
      dest = @prev_node(node_id)
      $(".editable[data-id='#{dest}']").focus()

    else if e.which == 40 # down
      e.preventDefault()
      dest = @next_node(node_id)
      $(".editable[data-id='#{dest}']").focus()

    else if e.which == 13 # enter
        e.preventDefault()
        x = $target.parentsUntil "ul.treeview"
        parent_id = $(x[2]).find(".editable").first().attr("data-id")

        $.post "/nodes", {parent_id: parent_id}, (response) ->
          focus_node = response.newNodeId
          console.log "post", focus_node
          $component.setState data: eval(response.data)

    else if e.which == 9 # tab
      e.preventDefault()
      focus_node = node_id
      if e.shiftKey
        x = $target.parentsUntil "ul.treeview"
        parent_nodes = x.filter("li.treenode")

        if parent_nodes.length >= 3
          newParent = $(parent_nodes[2])
          newParentId = newParent.find('.editable').first().attr 'data-id'
        else
          # root
          newParentId = null

        @update_node(node_id, newParentId)

      else
        x = $target.parents('li.treenode').first().prev()
        if x.hasClass "treenode"
          ed = x.find('.editable')
          newParentId = ed.attr('data-id')

          @update_node(node_id, newParentId)
        else
          return

  update_node: (node_id, newParentId) ->
    $component = this
    $.ajax(
      type: "PUT"
      url: "/nodes/#{node_id}"
      data:
        node:
          title: $(".editable[data-id='" + node_id + "'] span:first").html()
          parent_id: newParentId
    ).done (response) ->
      $component.setState data: response

  next_node: (id) ->
      all = $('.editable').map ->
        $(this).attr "data-id"
      ix = $.inArray id, all
      if ix == all.length - 1
        ix = -1
      all[ix+1]

  prev_node: (id) ->
      all = $('.editable').map ->
        $(this).attr "data-id"
      ix = $.inArray id, all
      if ix == 0
        ix = all.length
      all[ix-1]

  handleChange: (id) ->
    console.log x

  render: ->
    `<div>
      <ul className="treeview" onKeyDown={this.handleKeyDown}>
      {this.state.data.map(function(node) {
        return <TreeNode node={node} key={node.id} />
      })}
      </ul>
    </div>`


@TreeNode = React.createClass
  componentDidMount: ->

  handleKeyDown: (e) ->




  render: ->
    if (this.props.node.children.length > 0)
      childNodes = this.props.node.children.map (node) ->
        return `<TreeNode node={node} key={node.id} />`

    return (
      `<li className="treenode">
        <div className="node editable" data-id={this.props.node.id} contentEditable>
        {this.props.node.title}
        <em> {this.props.node.id} </em>
        </div>
          <ul>
            {childNodes}
          </ul>
      </li>`
    )

