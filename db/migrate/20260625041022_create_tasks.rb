class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :task_order, null: false
      t.string :task_name, null: false
      t.time :task_time, null: false
      t.boolean :done, null: false

      t.timestamps
    end
  end
end
