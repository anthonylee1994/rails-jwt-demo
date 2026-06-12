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

  it "converts username to lower case before validation" do
    user = described_class.create!(username: "Anthony", password: "password123")

    expect(user.username).to eq("anthony")
  end

  it "allows letters numbers dots underscores and hyphens in username" do
    user = described_class.new(username: "Anthony_1-Test", password: "password123")

    expect(user).to be_valid
    expect(user.username).to eq("anthony_1-test")
  end

  it "requires username to start and end with a letter or number" do
    starts_with_symbol = described_class.new(username: "_anthony", password: "password123")
    ends_with_symbol = described_class.new(username: "anthony_", password: "password123")

    expect(starts_with_symbol).not_to be_valid
    expect(ends_with_symbol).not_to be_valid
  end

  it "requires username to match the allowed length" do
    user = described_class.new(username: "abc1", password: "password123")

    expect(user).not_to be_valid
  end

  it "requires password to be at least 8 characters" do
    user = described_class.new(username: "anthony", password: "short")

    expect(user).not_to be_valid
    expect(user.errors[:password]).to include("is too short (minimum is 8 characters)")
  end

  it "does not re-validate password length on update" do
    user = described_class.create!(username: "anthony", password: "password123")
    user.username = "anthony2"

    expect(user).to be_valid
  end
end
