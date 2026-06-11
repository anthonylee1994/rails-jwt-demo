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

require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with a username and password" do
    user = described_class.new(username: "anthony", password: "password123")

    expect(user).to be_valid
  end

  it "requires a unique username" do
    described_class.create!(username: "anthony", password: "password123")

    user = described_class.new(username: "anthony", password: "password456")

    expect(user).not_to be_valid
    expect(user.errors[:username]).to include("has already been taken")
  end
end
