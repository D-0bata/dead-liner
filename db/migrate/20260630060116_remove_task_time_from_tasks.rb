class RemoveTaskTimeFromTasks < ActiveRecord::Migration[8.1]
  def change
    remove_column :tasks, :task_time, :time, null: false
  end
end
