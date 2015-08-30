class Participant < ActiveRecord::Base
  belongs_to(:joinable, { polymorphic: true })
  belongs_to(:user)
end
