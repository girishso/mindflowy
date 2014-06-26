class NodesController < ApplicationController

  def index
    tree = [{
  title: "howdy",
  id: 1,
  children: [
    {title: "bobby", id: 2, children:[]},
    {title: "suzie", id: 3, children: [
      {title: "puppy", id: 4, children: [
        {title: "dog house", id: 5, children: [
          {title: "aaaaa", id: 6, children:[]}
        ]}
      ]},
      {title: "cherry tree", id: 7, children:[]}
    ]}
  ]
},
{
  title: "NOwdy", children:[], id:8
}  ]

    puts current_user.nodes.arrange_serializable.to_json
    respond_to do |format|
      format.json { render json:  
                   tree # current_user.nodes.arrange_serializable.to_json 
      }
    end
  end

  def create
    node = Node.new node_params

    if node.save
      respond_to do |format|
        format.json { render json: current_user.nodes.arrange_serializable.to_json, status: 200}
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
