class AddCountdownToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :countdown, :boolean, null: false
  end
end
