class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :tasks

  normalizes :email,
    with: ->(email) { email.strip.downcase }

  validates :guest,
    inclusion: [ true, false ]

  validates :email,
    presence: true,
    uniqueness: true,
    format: { with: /\Aguest_[0-9]{11,12}@example.com\z/ }, if: :guest?

    def guest?
      guest
    end
end
