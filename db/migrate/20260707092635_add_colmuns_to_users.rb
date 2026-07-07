class AddColmunsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :done_tasks_count, :integer, default: 0
    add_column :users, :total_tasks_count, :integer, default: 0
  end
end
