class ChangePositionInNodes < ActiveRecord::Migration
  def change
    change_column :nodes, :position, :decimal
  end
end
