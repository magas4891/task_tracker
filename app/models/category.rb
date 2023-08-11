class Category < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy

  scope :populated_category_tasks, -> { joins(:tasks).distinct }
end
