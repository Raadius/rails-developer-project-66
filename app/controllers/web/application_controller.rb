# frozen_string_literal: true

module Web
  class ApplicationController < ::ApplicationController
    include Pundit::Authorization

    helper_method :current_user

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def current_user
      return @current_user if defined?(@current_user)

      @current_user = User.find_by(id: session[:user_id])
    end

    def user_not_authorized
      flash[:alert] = t('notices.not_authorized')
      redirect_to root_path
    end
  end
end
