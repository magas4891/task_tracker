class UpdateCategoriesColumns < ActiveRecord::Migration[7.0]
  def change
    remove_belongs_to :categories, :user
    add_belongs_to :categories, :dashboard
  end
end
