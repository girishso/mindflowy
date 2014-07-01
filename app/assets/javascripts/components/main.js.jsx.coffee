###* @jsx React.DOM ###

focus_node = null

@TreeView = React.createClass
  getInitialState: ->
    return {data: []}

  componentDidMount: ->
    that = this
    $.getJSON("/nodes", null, (d) ->
      console.log d
      that.setState data: d
    )

  componentDidUpdate: ->
    console.log "componentDidUpdate", focus_node
    if focus_node?
      $(".editable[data-id='#{focus_node}']").focus()
      focus_node = null

  handleKeyDown: (e) ->
    $target = $(e.target)
    node_id = $target.attr("data-id")
    position = parseFloat $target.attr("data-position")
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

      next_sibling = $("li[data-id=#{node_id}] + li")
      if next_sibling.length
        next_sibling_position = parseFloat next_sibling.attr("data-position")
        newPosition = (position + next_sibling_position) / 2
      else
        newPosition = position + 200

      $.post "/nodes", {parent_id: parent_id, position: newPosition}, (response) ->
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
          title: $(".editable[data-id='#{node_id}']").html()
          parent_id: newParentId
    ).done (response) ->
      console.log response
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

  render: ->
    `<div>
      <ul className="treeview" onKeyDown={this.handleKeyDown}>
      {this.state.data.map(function(node) {
        return <TreeNode node={node} key={node.id} />
      })}
      </ul>
    </div>`


@TreeNode = React.createClass
  onChange: (e) ->
    console.log "in on change", e
    $.ajax
      type: "PUT"
      url: "/nodes/#{e.target.node_id}"
      data:
        node:
          title: e.target.value


  render: ->
    if (this.props.node.children.length > 0)
      childNodes = this.props.node.children.map (node) ->
        return `<TreeNode node={node} key={node.id} />`

    node = @props.node
    return (
      `<li className="treenode" data-id={node.id} data-position={node.position}>
        <ContentEditable 
          html={node.title}
          node_id={this.props.key}
          position={node.position}
          onChange={this.onChange} />

        <em>id: {node.id}</em>
        <em className="position">{node.position}</em>
          <ul>
            {childNodes}
          </ul>
      </li>`
    )

ContentEditable = React.createClass(
  render: ->
    `<div
         className="node editable"
         data-id={this.props.node_id}
         data-position={this.props.position}
            onBlur={this.emitChange}
            onFocus={this.handleFocus}
            contentEditable
            onChange={this.props.onChange}
            dangerouslySetInnerHTML={{__html: this.props.html}}>
      </div>
    `

  handleFocus: (e) ->
    $this = $(e.target)
    $this.data('before', $this.html())

  shouldComponentUpdate: (nextProps) ->
    nextProps.html isnt @getDOMNode().innerHTML

  emitChange: ->
    $this = $(@getDOMNode())
    html = $this.html()

    if @props.onChange and html isnt $this.data('before')
      @props.onChange target:
        value: html
        node_id: $this.attr('data-id')

    $this.data('before', html)
    return
)
