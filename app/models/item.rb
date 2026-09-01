class Item < ApplicationRecord
  belongs_to :todo

  validates :content, presence: true, length: { minimum: 1, maximum: 500 }
  
  scope :ordered, -> { order(position: :asc, created_at: :asc) }

  before_validation :set_default_position, on: :create

  private

  def set_default_position
    return if position.present?

    self.position = (todo&.items&.maximum(:position) || 0) + 1
  end
end
