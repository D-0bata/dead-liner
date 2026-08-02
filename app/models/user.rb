class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :tasks, -> { order(:task_order) }

  validate :email_format

  validates :guest,
    inclusion: [ true, false ]

  normalizes :email,
    with: ->(email) { email.strip.downcase }

  validates :email,
    presence: true,
    uniqueness: true,
    length: { maximum: 255, too_long: "email must be less than or equal to 255 characters" }

  validates :total_tasks_count,
    presence: true,
    numericality: { only_integer: true, in: 0..255 }

  validates :done_tasks_count,
    presence: true,
    numericality: { only_integer: true, in: 0..255 },
    comparison: { less_than_or_equal_to: :total_tasks_count }

  validates :working_task_order,
    presence: true,
    numericality: { only_integer: true, in: 0..255 },
    comparison: { less_than_or_equal_to: :total_tasks_count }

  private
    def email_format
      if guest
        if !(email && email.match?(/\Aguest_[0-9]{11,12}@example.com\z/))
          errors.add(:email, "invalid email format for a guest user")
        end
      else
        if !(email && !email.match?(/\Aguest_[0-9]{11,12}@example.com\z/) && email.match?(URI::MailTo::EMAIL_REGEXP))
          errors.add(:email, "invalid email format for a sign-in user")
        end
      end
    end
end
