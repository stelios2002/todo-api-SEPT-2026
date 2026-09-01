class Todo < ApplicationRecord
  belongs_to :user
  has_many :items, dependent: :destroy

  validates :title, presence: true, length: { minimum: 2, maximum: 200 }
  validates :description, length: { maximum: 1000 }, allow_blank: true

  scope :recent, -> { order(created_at: :desc) }
  scope :oldest, -> { order(created_at: :asc) }
  scope :done, -> { where(completed: true) }
  scope :pending, -> { where(completed: false) }
end
