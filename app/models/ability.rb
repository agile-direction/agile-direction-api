class Ability
  include CanCan::Ability

  def initialize(user)
    can(:read, Mission, { public: true })
    can(:manage, Mission) do |mission|
      mission.users.none?
    end

    can(:manage, Participant) do |participant|
      participant.joinable.users.none?
    end

    can(:manage, Requirement) do |requirement|
      requirement.mission.public?
    end

    return unless user

    can(:manage, user)
    can(:manage, Mission) do |mission|
      mission.users.include?(user)
    end
    can(:manage, Participant) do |participant|
      participant.joinable.users.include?(user)
    end
    can(:manage, Requirement) do |requirement|
      requirement.mission.users.include?(user)
    end
  end
end
