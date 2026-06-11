# == Schema Information
#
# Table name: tasks
#
#  id         :string(36)       not null, primary key
#  name       :string
#  completed  :boolean          default(FALSE)
#  user_id    :string(36)       not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tasks_on_user_id  (user_id)
#

require 'rails_helper'

RSpec.describe Task, type: :model do
  it "is valid with a name, completed state, and user" do
    user = User.create!(username: "anthony", password: "password123")
    task = described_class.new(name: "Build API", completed: false, user:)

    expect(task).to be_valid
  end

  it "defaults completed to false" do
    user = User.create!(username: "anthony", password: "password123")
    task = user.tasks.create!(name: "Build API")

    expect(task.completed).to be(false)
  end

  it "requires a completed boolean" do
    user = User.create!(username: "anthony", password: "password123")
    task = described_class.new(name: "Build API", completed: nil, user:)

    expect(task).not_to be_valid
    expect(task.errors[:completed]).to include("is not included in the list")
  end
end
