class Task < ApplicationRecord
  STATUSES = {
    created: 0,
    in_progress: 1,
    pending: 2,
    completed: 3
  }.freeze

  enum status: STATUSES

  belongs_to :user
end
