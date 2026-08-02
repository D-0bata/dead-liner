class ChangeColumnsNullInTasks < ActiveRecord::Migration[8.1]
  def change
    change_column_null :tasks, :timer_started_at, false
    change_column_null :tasks, :timer_stopped_at, false
    change_column_null :tasks, :elapsed_task_time, false
  end
end
