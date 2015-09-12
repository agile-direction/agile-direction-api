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

  private

  def auth_key
    ApplicationController::USER_AUTHENTICATION_KEY
  end
end
