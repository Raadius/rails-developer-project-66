# frozen_string_literal: true

module Web
  module Authentication
    extend ActiveSupport::Concern

    included do
      helper_method :current_user
    end

    def current_user
      return @current_user if defined?(@current_user)

      @current_user = User.find_by(id: session[:user_id])
    end

    def check_auth!
      return if current_user.present?

      flash[:alert] = t('notices.not_authorized')
      redirect_to root_path
    end
  end
end
