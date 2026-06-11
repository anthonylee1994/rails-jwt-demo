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
  USERNAME_FORMAT = /\A[a-zA-Z0-9][a-zA-Z0-9._-]{3,18}[a-zA-Z0-9]\z/

  has_many :tasks, dependent: :destroy

  before_validation :downcase_username

  validates :username, presence: true, uniqueness: true
  validates :username, format: { with: USERNAME_FORMAT }
  validates :password_digest, presence: true

  has_secure_password

  def token
    JsonWebToken.encode({ username:, sub: id })
  end

  def self.from_token(token)
    payload = JsonWebToken.decode(token)
    find(payload["sub"])
  end

  private

  def downcase_username
    self.username = username&.downcase
  end
end
