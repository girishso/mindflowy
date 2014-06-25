class Node < ActiveRecord::Base
  # acts_as_nested_set
  has_ancestry
  # attr_accessible :title, :parent_id
end
