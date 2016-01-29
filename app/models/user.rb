class User < ActiveRecord::Base
  has_secure_password

  validates :email, uniqueness: true
  validates :email, format: {with: /\A[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+\z/}

end
