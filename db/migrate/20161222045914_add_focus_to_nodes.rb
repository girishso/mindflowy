class AddFocusToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :focus, :boolean, default: false
  end
end
