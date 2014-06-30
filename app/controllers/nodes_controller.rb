class NodesController < ApplicationController

  def index
    puts current_user.nodes.arrange_serializable.to_json
    respond_to do |format|
      format.json { render json:
        current_user.nodes.arrange_serializable.to_json
      }
    end
  end

  def create
    if params[:parent_id].present?
      node = Node.find params[:parent_id]
      child = node.children.new
    else
      child = Node.new
    end

    child.user_id = current_user.id

    if child.save
      respond_to do |format|
        format.json { render json: {newNodeId: child.id, data: current_user.nodes.arrange_serializable.to_json}, status: 200}
      end
    else
      respond_to do |format|
        format.json { render json: current_user.nodes.arrange_serializable.to_json, status: :unprocessable_entity }
      end
    end
  end

  def update
    node = Node.find(params[:id])

    respond_to do |format|
      if node.update(node_params)
        format.json { render json: current_user.nodes.arrange_serializable.to_json, status: 200}
      else
        format.json { render json: current_user.nodes.arrange_serializable.to_json, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    node = Node.find(params[:id])
    node.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def node_params
      params.require(:node).permit(:title, :parent_id, :description, :position)
    end

end
