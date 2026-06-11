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

class Task < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :completed, inclusion: { in: [ true, false ] }
end
