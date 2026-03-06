# frozen_string_literal: true

module Web
  class RepositoriesController < Web::ApplicationController
    before_action :check_auth

    def index
      skip_authorization
      @repositories = policy_scope(Repository)
    end

    def show
      @repository = current_user.repositories.find(params[:id])

      authorize @repository
      @checks = @repository.checks.recent
    end

    def new
      authorize Repository, :new?
      client = GithubClientFactory.for_user(current_user)

      github_repos = client.repos(user: current_user.nickname)
      @github_repositories = github_repos.select { |rep| Repository.language.values.include?(rep.language&.downcase) }
      @repository = current_user.repositories.build
    end

    def create
      authorize Repository, :create?
      github_id = params.dig(:repository, :github_id).to_i
      client = GithubClientFactory.for_user(current_user)
      repo_info = client.repository(github_id)

      @repository = current_user.repositories.find_or_initialize_by(github_id: github_id)
      @repository.assign_attributes(
        name: repo_info.name,
        full_name: repo_info.full_name,
        language: repo_info.language&.downcase,
        clone_url: repo_info.clone_url,
        ssh_url: repo_info.ssh_url
      )

      if @repository.save
        webhook_url = Rails.application.routes.url_helpers.api_checks_url
        client.create_hook(
          @repository.full_name,
          'web',
          { url: webhook_url, content_type: 'json', secret: ENV.fetch('GITHUB_WEBHOOK_SECRET') },
          { events: ['push'], active: true }
        )
        redirect_to repositories_path, notice: t('notices.repository_created')
      else
        render :new, status: :unprocessable_content
      end
    end
  end
end
