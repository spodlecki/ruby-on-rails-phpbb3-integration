
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user
  before_filter :update_user_session

  # Will call the update_user_session every request. I've considered having this cached and only firing every 10 minutes or so to reduce sql hits.
  def update_user_session
    if current_user
      User.update_user_session(cookies,request)
    end
  end
  private
    # You can call "current_user" anywhere in your controllers, views, and helpers
    def current_user
      return @current_user if defined?(@current_user)
      @current_user = User.get_user_from_cookies(cookies)
      return @current_user
    end
end
