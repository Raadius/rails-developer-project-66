# frozen_string_literal: true

module Web
  class RepositoriesController < Web::ApplicationController
    before_action :check_auth!

    SUPPORTED_LANGUAGES = Repository.language.values

    def index
      @repositories = current_user.repositories.page(params[:page])
    end

    def show
      @repository = current_user.repositories.find(params[:id])
      authorize @repository
      @checks = @repository.checks.recent.page(params[:page])
    end

    def new
      client = GithubClientFactory.for_user(current_user)
      github_repos = client.repos(user: current_user.nickname)
      @github_repositories = github_repos.select { |rep| SUPPORTED_LANGUAGES.include?(rep.language&.downcase) }
      @repository = current_user.repositories.build
    end

    def create
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
        RegisterRepositoryWebhookJob.perform_later(@repository.id)
        redirect_to repositories_path, notice: t('notices.repository_created')
      else
        render :new, status: :unprocessable_content
      end
    end
  end
end
