class Node < ActiveRecord::Base
  has_ancestry
  # attr_accessible :title, :parent_id

  def self.ensure_node_must_exist_for_user(user_id)
    unless Node.exists?(user_id: user_id)
      Node.create title: "Remember the milk!", user_id: user_id, position: 1.0
    end
  end
end
