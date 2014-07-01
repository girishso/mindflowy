###* @jsx React.DOM ###

focus_node = null

@TreeView = React.createClass
  getInitialState: ->
    return {data: []}

  componentDidMount: ->
    that = this
    $.getJSON("/nodes", null, (d) ->
      that.setState data: d
    )

  componentDidUpdate: ->
    if focus_node?
      $("[data-id='#{focus_node}']").children(".editable").focus()
      focus_node = null

  handleKeyDown: (e) ->
    $target = $(e.target)
    node_id = $target.parent("li").attr("data-id")
    position = parseFloat $target.parent("li").attr("data-position")
    $component = this

    if e.which == 38 # up
      e.preventDefault()
      dest = @prev_node(node_id)
      $("[data-id='#{dest}']").children(".editable").focus()

    else if e.which == 40 # down
      e.preventDefault()
      dest = @next_node(node_id)
      $("[data-id='#{dest}']").children(".editable").focus()

    else if e.which == 13 # enter
      e.preventDefault()
      x = $target.parentsUntil "ul.treeview"
      parent_id = $(x[2]).attr("data-id")

      next_sibling = $("li[data-id=#{node_id}] + li")
      if next_sibling.length
        next_sibling_position = parseFloat next_sibling.attr("data-position")
        newPosition = (position + next_sibling_position) / 2
      else
        newPosition = position + 200

      $.post "/nodes", {parent_id: parent_id, position: newPosition}, (response) ->
        focus_node = response.newNodeId
        $component.setState data: eval(response.data)

    else if e.which == 9 # tab
      e.preventDefault()
      focus_node = node_id
      if e.shiftKey
        x = $target.parentsUntil "ul.treeview"
        parent_nodes = x.filter("li.treenode")

        if parent_nodes.length >= 3
          newParent = $(parent_nodes[2])
          newParentId = newParent.first().attr 'data-id'
        else if parent_nodes.length == 1
          # shiftkey pressed on root node
          return
        else
          # root
          newParentId = null

        @update_node(node_id, newParentId, @newPosition(node_id, newParentId))

      else
        x = $target.parents('li.treenode').first().prev()
        if x.hasClass "treenode"
          newParentId = x.attr('data-id')

          @update_node(node_id, newParentId, @newPosition(node_id, newParentId))
        else
          return

  newPosition: (node_id, parent_id) ->
    if parent_id?
      prev_sibling = $("[data-id=#{parent_id}] > ul > li:last-child")
      position = parseFloat prev_sibling.attr("data-position")
      if isNaN position
        position = 1.0
      else
        position += 200.0
    else
      prev_sibling = $("[data-id=#{node_id}]").parents(".treenode")
      prev_sibling_id = prev_sibling.attr("data-id")
      prev_sibling_position = parseFloat prev_sibling.attr("data-position")
      next_sibling_position = parseFloat $("[data-id=#{prev_sibling_id}] + li").attr("data-position")
      if isNaN next_sibling_position
        position = prev_sibling_position + 200
      else
        position = (prev_sibling_position + next_sibling_position) / 2

    position

  update_node: (node_id, newParentId, newPosition) ->
    $component = this
    $.ajax(
      type: "PUT"
      url: "/nodes/#{node_id}"
      data:
        node:
          title: $("[data-id='#{node_id}']").find(".editable").html()
          parent_id: newParentId
          position: newPosition
    ).done (response) ->
      $component.setState data: response

  next_node: (id) ->
    all = $('.treenode').map ->
      $(this).attr "data-id"
    ix = $.inArray id, all
    if ix == all.length - 1
      ix = -1
    all[ix+1]

  prev_node: (id) ->
    all = $('.treenode').map ->
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
          onChange={this.onChange} />
          <ul>
            {childNodes}
          </ul>
      </li>`
    )

ContentEditable = React.createClass(
  render: ->
    html = this.props.html
    html = "&nbsp;" if html is null
    `<div
         className="node editable"
            onBlur={this.emitChange}
            onFocus={this.handleFocus}
            contentEditable
            onChange={this.props.onChange}
            dangerouslySetInnerHTML={{__html: html}}>
      </div>
    `

  handleFocus: (e) ->
    $this = $(e.target)
    html = $this.html()
    @selectText(e.target) if html is "&nbsp;"
    $this.data('before', html)

  shouldComponentUpdate: (nextProps) ->
    nextProps.html isnt @getDOMNode().innerHTML

  emitChange: ->
    $this = $(@getDOMNode())
    html = $this.html()

    if @props.onChange and html isnt $this.data('before')
      @props.onChange target:
        value: html
        node_id: $this.parent().attr("data-id")

    $this.data('before', html)
    return

  selectText: (element) ->
    doc = document
    text = element
    range = undefined
    selection = undefined
    if doc.body.createTextRange #ms
      range = doc.body.createTextRange()
      range.moveToElementText text
      range.select()
    else if window.getSelection #all others
      selection = window.getSelection()
      range = doc.createRange()
      range.selectNodeContents text
      selection.removeAllRanges()
      selection.addRange range
)
