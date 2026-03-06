# frozen_string_literal: true

module Web
  class AuthController < ApplicationController
    skip_after_action :verify_authorized

    def callback
      auth = request.env['omniauth.auth']

      user = User.find_or_initialize_by(email: auth[:info][:email].downcase)
      user.nickname = auth[:info][:nickname]
      user.email = auth[:info][:email]
      user.token = auth[:credentials][:token]

      if user.save
        session[:user_id] = user.id
        redirect_to root_path, notice: t('notices.signed_in_successful')
      else
        redirect_to root_path, notice: t('notices.signed_in_failed')
      end
    end

    def failure
      redirect_to root_path, alert: t('notices.user.auth_error')
    end

    def logout
      reset_session
      redirect_to root_path, notice: t('notices.logged_out')
    end
  end
end
