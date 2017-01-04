class NodesController < ApplicationController

  def index
    puts user_nodes.to_json
    respond_to do |format|
      format.html
      format.json { render json: user_nodes.to_json, status: 200 }
    end
  end

  def create
    puts params.to_yaml
    if params[:parent_id].present?
      node = Node.find params[:parent_id]
      child = node.children.new position: params[:position]
    else
      child = Node.new position: params[:position]
    end

    child.user_id = current_user.id

    if child.save
      respond_to do |format|
        format.json { render json: {newNodeId: child.id, data: user_nodes.to_json}, status: 200}
      end
    else
      respond_to do |format|
        format.json { render json: user_nodes.to_json, status: :unprocessable_entity }
      end
    end
  end

  def update
    node = Node.find(params[:id])

    respond_to do |format|
      if node.update(node_params)
        format.json { render json: user_nodes.to_json, status: 200}
      else
        format.json { render json: user_nodes.to_json, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    node = Node.find(params[:id])
    node.destroy
    Node.ensure_node_must_exist_for_user(current_user.id)

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def node_params
      params.require(:node).permit(:title, :parent_id, :description, :position)
    end

    def user_nodes
      current_or_guest_user.nodes.arrange_serializable(order: :position)
    end

end
