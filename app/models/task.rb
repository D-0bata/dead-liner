class Task < ApplicationRecord
  belongs_to :user

  validate :time_class?

  validates :task_order,
    presence: true,
    numericality: { only_integer: true, in: 1..255 }

  validates :task_name,
    presence: true,
    length: { in: 1..255 }

  validates :task_time,
    presence: true,
    numericality: { only_integer: true, in: 1..(24 * 60 * 60) }

  validates :done_flag,
    inclusion: [ true, false ]

  validates :timer_flag,
    inclusion: [ true, false ]

  validates :timer_started_at, :timer_stopped_at,
    presence: true

  validates :elapsed_task_time,
    presence: true,
    numericality: { only_integer: true, in: 0.. }

  private
    def time_class?
      if !timer_started_at.is_a?(ActiveSupport::TimeWithZone)
        errors.add(:timer_started_at, "must be an instance of time class")
      end
      if !timer_stopped_at.is_a?(ActiveSupport::TimeWithZone)
        errors.add(:timer_stopped_at, "must be an instance of time class")
      end
    end
end
