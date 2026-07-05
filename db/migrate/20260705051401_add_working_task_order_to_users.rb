class AddWorkingTaskOrderToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :working_task_order, :integer, default: 0
  end
end
