class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.belongs_to :user

      t.string :title
      t.text :description
      t.date :due_date
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
