class Node < ActiveRecord::Base
  has_ancestry
  # attr_accessible :title, :parent_id

  def self.ensure_node_must_exist_for_user(user_id)
    unless Node.exists?(user_id: user_id)
      work = Node.create title: "Work", user_id: user_id, position: 1.0
      projects = Node.create title: "Projects", user_id: user_id, position: 1.0, parent: work

      mindflowy = Node.create title: "MindFlowy", user_id: user_id, position: 1.0, parent: projects
      Node.create title: "Deploy on Heroku", user_id: user_id, position: 1.0, parent: mindflowy
      work = Node.create title: "Learn Swift", user_id: user_id, position: 100.0, parent: projects

      personal = Node.create title: "Personal", user_id: user_id, position: 100.0
      Node.create title: "Remember the milk!", user_id: user_id, position: 1.0, parent: personal
    end
  end
end
