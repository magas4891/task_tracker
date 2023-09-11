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

  scope :categorized, -> { where.not(category_id: nil) }
  scope :uncategorized, -> { where(category_id: nil) }

  acts_as_list scope: [:category_id, :user_id]

  after_create { self.move_to_top }
end
