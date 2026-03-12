# frozen_string_literal: true

module Web
  class ApplicationController < ::ApplicationController
    include Pundit::Authorization
    include Web::Authentication

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def user_not_authorized
      flash[:alert] = t('notices.not_authorized')
      redirect_to root_path
    end
  end
end
