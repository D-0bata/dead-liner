class RenameColumnsInTasks < ActiveRecord::Migration[8.1]
  def change
    rename_column :tasks, :countdown, :countdown_flag
    rename_column :tasks, :done, :done_flag
  end
end
