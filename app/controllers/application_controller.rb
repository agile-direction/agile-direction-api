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

  def generate_links(query, page, limit)
    {}.tap do |links|
      has_next_page = (query.count > ((page + 1) * limit))
      links[:next] = yield(page + 1) if has_next_page
      if (page > 0)
        links[:previous] = (page == 1) ? yield(nil) : yield(page - 1)
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
