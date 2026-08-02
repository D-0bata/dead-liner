class AddTaskTimeToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :task_time, :integer, null: false
  end
end
