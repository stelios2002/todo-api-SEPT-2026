class Item < ApplicationRecord
  belongs_to :todo

  validates :content, presence: true
end
