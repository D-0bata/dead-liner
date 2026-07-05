class RenameCountdownFlagInTasks < ActiveRecord::Migration[8.1]
  def change
    rename_column :tasks, :countdown_flag, :timer_flag
  end
end
