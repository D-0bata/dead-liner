class AddColumnsToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :timer_started_at, :datetime, default: -> { 'NOW()' }
    add_column :tasks, :timer_stopped_at, :datetime, default: -> { 'NOW()' }
    add_column :tasks, :elapsed_task_time, :integer, default: 0
  end
end
