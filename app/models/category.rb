class Category < ApplicationRecord
  belongs_to :dashboard

  has_many :tasks, dependent: :destroy

  scope :populated_category_tasks, -> { joins(:tasks).distinct }

  acts_as_list sequential_updates: false, scope: :dashboard
end
