class ApplicationController < ActionController::Base
  USER_AUTHENTICATION_KEY = "keep-delivering.authentication"

  protect_from_forgery({ with: :exception })

  helper_method(:current_user)

  rescue_from(CanCan::AccessDenied) do
    respond_to do |format|
      format.html do
        render("errors/unauthorized", { status: 403 })
      end
      format.json do
        head(403)
      end
    end
  end

  def require_user!
    return true if current_user
    flash[:alert] = t("flashes.must-login")
    session[:path_requiring_authentication] = request.fullpath
    redirect_to(auth_path, { status: 302 })
    false
  end

  def current_user
    return unless session[USER_AUTHENTICATION_KEY]
    user = User.find(session_user_id)
    (user.test == session_user_test) ? user : nil
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def current_user=(user)
    session[USER_AUTHENTICATION_KEY] = parameterized_user(user)
  end

  def log_out!
    reset_session
  end

  private

  def parameterized_user(user)
    [user.id, user.test]
  end

  def session_user_id
    session[USER_AUTHENTICATION_KEY][0]
  end

  def session_user_test
    session[USER_AUTHENTICATION_KEY][1]
  end
end
