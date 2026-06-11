# == Schema Information
#
# Table name: users
#
#  id              :string(36)       not null, primary key
#  username        :string
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :username, presence: true, uniqueness: true
  validates :password_digest, presence: true

  has_secure_password

  def token
    JsonWebToken.encode({ username:, sub: id })
  end

  def self.from_token(token)
    payload = JsonWebToken.decode(token)
    find(payload["sub"])
  end
end
