# frozen_string_literal: true

class CheckMailer < ApplicationMailer
  def failed(check)
    @check = check
    @repository = check.repository
    @user = @repository.user

    mail(
      to: @user.email,
      subject: t('mailers.check_mailer.failed.subject',
                 repo: @repository.full_name)
    )
  end
end
