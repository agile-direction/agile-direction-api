module Assemblers
  class User
    class << self
      def glue!(data)
        user = new(data)
        user.save!
      end
    end

    attr_accessor :user

    def initialize(data)
      uid = data["uid"]
      info = data.fetch("info", {})
      name = info["name"]
      image_uri = info["image"]
      location = info["location"]

      self.user = ::User.find_or_initialize_by({
        source_id: uid
      })

      user.name = name
      user.source_id = uid
      user.source = ::User::SOURCES.fetch(:twitter)
      user.image_uri = image_uri
      user.location = location
    end

    def save!
      validate!
      user.save!
      user
    end

    def validate!
      invalid_attributes = %w(source source_id).each_with_object([]) do |field, attributes|
        attributes << field if user.attributes.fetch(field).blank?
      end

      unless user.valid?
        invalid_attributes += user.errors.messages.keys.collect(&:to_s)
      end

      raise(InvalidData, invalid_attributes) if invalid_attributes.any?
    end
  end
end
