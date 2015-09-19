class OmniauthController < ApplicationController
  rescue_from(Assemblers::InvalidData) do |error|
    Rails.logger.error({ error: error.to_s, userParams: user_params })
    redirect_to(auth_twitter_failure_path)
  end

  def authenticate
  end

  def callback
    self.current_user = Assemblers::User.glue!(user_params)
    redirect_path = (session[:path_requiring_authentication] || user_path(current_user))
    redirect_to(redirect_path)
  end

  def failure
    render({ status: 400 })
  end

  def logout
    log_out!
    redirect_to(root_path)
  end

  private

  def user_params
    request.env["omniauth.auth"].to_hash
  end
end
