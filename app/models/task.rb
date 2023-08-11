class Task < ApplicationRecord
  STATUSES = {
    created: 0,
    in_progress: 1,
    pending: 2,
    completed: 3
  }.freeze

  enum status: STATUSES

  belongs_to :user
  belongs_to :category, optional: true

  scope :category_tasks, -> (category_id) { where('category_id = ?', category_id) }
end
