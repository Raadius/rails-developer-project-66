# frozen_string_literal: true

class RegisterRepositoryWebhookJob < ApplicationJob
  queue_as :default

  def perform(repository_id)
    repository = Repository.find(repository_id)
    client = GithubClientFactory.for_user(repository.user)
    webhook_url = Rails.application.routes.url_helpers.api_checks_url

    hooks = client.hooks(repository.full_name)
    return if hooks.any? { |h| h.config.url == webhook_url }

    client.create_hook(
      repository.full_name,
      'web',
      { url: webhook_url, content_type: 'json', secret: ENV.fetch('GITHUB_WEBHOOK_SECRET', nil) }.compact,
      { events: ['push'], active: true }
    )
  end
end
