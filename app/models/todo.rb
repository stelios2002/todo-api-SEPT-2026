class Todo < ApplicationRecord
  belongs_to :user
  has_many :items, dependent: :destroy

  validates :title, presence: true, length: { minimum: 2, maximum: 200 }

  after_initialize { self.completed = false if completed.nil? }

  scope :recent, -> { order(created_at: :desc) }
end
