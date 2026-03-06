# frozen_string_literal: true

module Api
  class ChecksController < Api::ApplicationController
    before_action :verify_github_signature

    def create
      payload = JSON.parse(request.body.read)
      github_id = payload.dig('repository', 'id')

      repository = Repository.find_by(github_id: github_id)
      return head :unprocessable_content unless repository

      check = repository.checks.create!
      ::RepositoryCheckJob.perform_later(check.id)

      head :ok
    end

    private

    def verify_github_signature
      secret = ENV.fetch('GITHUB_WEBHOOK_SECRET', nil)
      return unless secret

      body = request.body.read
      request.body.rewind

      signature = "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', secret, body)}"
      return if ActiveSupport::SecurityUtils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE_256'].to_s)

      head :forbidden
    end
  end
end
