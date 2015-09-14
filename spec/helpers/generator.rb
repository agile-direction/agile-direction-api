class Generator
  VALID_FIXTURES = {
    mission: -> { {
      name: Faker::Name.name,
      public: true
    } },
    deliverable: -> { {
      name: Faker::Name.name,
      mission: make(:mission)
    } },
    requirement: -> { {
      name: Faker::Name.name,
      deliverable: make(:deliverable)
    } },
    user: -> { {
      name: Faker::Name.name
    } }
  }.freeze

  class << self
    # Generator.mission # initialize valid mission
    # Generator.mission({ specific: :data }) # initialize with data
    # Generator.mission! # initialize and persist
    def method_missing(method_symbol, *args)
      fixture_name, save = (/(\w+)(!)?/).match(method_symbol).captures
      super unless VALID_FIXTURES.key?(fixture_name.to_sym)
      save ? make!(fixture_name, *args) : make(fixture_name, *args)
    end

    def make(name, data = {})
      fixture_data = data_for(name)
      raise(ArgumentError, "No fixture data found for #{name}") unless fixture_data
      name.to_s.camelize.constantize.new(fixture_data.merge(data))
    end

    def make!(name, data = {})
      record = make(name, data)
      record.save!
      record
    end

    def data_for(name)
      fixture_proc = VALID_FIXTURES[name.to_sym]
      fixture_proc.call if fixture_proc
    end
  end
end
