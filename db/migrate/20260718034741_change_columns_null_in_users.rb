class ChangeColumnsNullInUsers < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users, :total_tasks_count, false
    change_column_null :users, :done_tasks_count, false
    change_column_null :users, :working_task_order, false
  end
end
