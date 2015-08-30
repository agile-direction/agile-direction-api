module APIHelpers
  def add_json_headers!
    @request.env["HTTP_ACCEPT"] = "application/json"
    @request.env["CONTENT_TYPE"] = "application/json"
  end

  def login!(user = nil)
    original_session = session[auth_key]
    session[auth_key] = [user.id, user.test] if user
    yield
    controller.instance_variable_set(:@current_ability, nil) # strike 2
  ensure
    session[auth_key] = original_session
  end

  def auth_key
    ApplicationController::USER_AUTHENTICATION_KEY
  end

  ###

  def with_api_test(route_params)
    api_test = APITest.new(self, route_params)
    yield(api_test)
  end

  def expect_change!(record, new_data)
    yield
    new_attributes = record.reload.attributes
    new_data.each do |(field, value)|
      expect(new_attributes.fetch(field.to_s)).to eq(value)
    end
  end

  class APITest
    attr_accessor :route_params,
      :test_instance

    def initialize(test_instance, route_params = {})
      self.test_instance = test_instance
      self.route_params = route_params
    end

    def new
      test_instance.get(:new, route_params)
    end

    def create!(valid_object)
      test_instance.post(:create, route_params.merge({
        valid_object.class.name.underscore => valid_object.attributes
      }))
    end

    def show(record)
      test_instance.get(:show, route_params.merge({
        id: record.id
      }))
    end

    def edit(record)
      test_instance.get(:edit, route_params.merge({
        id: record.id
      }))
    end

    def update!(record, new_data)
      test_instance.put(:update, route_params.merge({
        id: record.id,
        record.class.name.underscore => new_data
      }))
    end

    def destroy!(record)
      test_instance.delete(:destroy, route_params.merge({
        id: record.id
      }))
    end
  end
end

module AuthHelpers
  def login!(user = nil)
    original_session = session[auth_key]
    session[auth_key] = [user.id, user.test] if user
    yield
    controller.instance_variable_set(:@current_ability, nil) # strike 2
  ensure
    session[auth_key] = original_session
  end

  def expect_createable!(valid_object, route_params = {})
    expect_status!(200) { get(:new, route_params) }
    expect_new_records!(valid_object.class, 1) do
      create!(valid_object, route_params)
    end
  end

  def expect_destroyable!(created_object, route_params = {})
    expect_collection_change!(created_object, -1) do
      api_destroy!(created_object, route_params)
    end
  end

  def api_destroy!(created_object, route_params)
    delete(:destroy, route_params.merge({
      id: created_object.id
    }))
  end

  def expect_manageable!(created_object, update_data, route_params = {})
    params = route_params.merge({ id: created_object.id })
    expect_status!(200) { get(:show, params) }
    expect_status!(200) { get(:edit, params) }
    expect_change!(created_object, update_data) do
      update!(created_object, update_data, params)
    end
  end
  alias :expect_updateable! :expect_manageable!

  def expect_unmanageable!(created_object, update_data, code, route_params = {})
    params = route_params.merge({ id: created_object.id })
    expect_status!(code) { get(:show, params) }
    expect_status!(code) { get(:edit, params) }

    original_attributes = created_object.attributes
    update!(created_object, update_data, route_params)
    expect(original_attributes).to eq(created_object.reload.attributes)
  end

  def create!(valid_object, route_params = {})
    post(:create, route_params.merge({
      valid_object.class.name.underscore => valid_object.attributes
    }))
    assigns(valid_object.class.name.underscore)
  end
  alias :api_create! :create!

  def update!(created_object, new_data, route_params = {})
    put(:update, route_params.merge({
      id: created_object.id,
      created_object.class.name.underscore => new_data
    }))
  end

  def expect_collection_change!(klass, number)
    result = nil
    expect {
      result = yield
    }.to change {
      klass.count
    }.by(number)
    result
  end

  def expect_new_records!(klass, number)
    result = nil
    expect {
      result = yield
    }.to change {
      klass.count
    }.by(number)
    result
  end

  private

  def expect_status!(code)
    yield
    expect(response.status).to eq(code)
  end

  def expect_login!
    yield
    expect(response).to redirect_to(auth_path)
  end

  def expect_unauthorized!
    yield
    expect(response.status).to eq(403)
  end

  def auth_key
    ApplicationController::USER_AUTHENTICATION_KEY
  end
end
