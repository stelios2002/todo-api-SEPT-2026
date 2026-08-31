class User < ApplicationRecord
  has_secure_password
  
  has_many :todos, dependent: :destroy

  before_save { self.email = email.downcase.strip } #trigger before user saving

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "is invalid" }
  validates :password, length: { minimum: 6 }, if: -> { password.present? }
end