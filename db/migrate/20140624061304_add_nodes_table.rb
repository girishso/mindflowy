class AddNodesTable < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.string :title
      t.text :description
      t.references :user
      t.integer :position
      t.string :ancestry
    end
    add_index :nodes, :ancestry
    add_index :nodes, :position
  end

  def self.down
    drop_table :nodes
    remove_index :nodes, :ancestry
    remove_index :nodes, :position
  end
end
