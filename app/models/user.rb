class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@\s]+@([^@.\s]+\.)+[^@.\s]+\z/ }
  
  validates :password, confirmation: true, :length => {:within => 6..40}
  validates :password_confirmation, presence: true

  validates :name, presence: true, :length => {:within => 4..20}

  has_many :shareds

  has_many :likes

end
