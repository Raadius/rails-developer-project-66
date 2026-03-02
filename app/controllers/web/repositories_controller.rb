# frozen_string_literal: true

module Web
  class RepositoriesController < Web::ApplicationController
    before_action :check_auth

    def index
      @repositories = current_user.repositories
    end

    def show
      @repository = current_user.repositories.find(params[:id])

      authorize @repository
      @checks = @repository.checks.order(created_at: :desc)
    end

    def new
      client = ApplicationContainer[:github_client].new(
        access_token: current_user.token,
        auto_paginate: true
      )

      languages = Repository.language.values

      github_repos = client.repos(user: current_user.nickname)
      @github_repositories = github_repos.select { |rep| languages.include?(rep.language&.downcase) }
      @repository = current_user.repositories.build
    end

    def create
      github_id = params.dig(:repository, :github_id).to_i
      client = ApplicationContainer[:github_client].new(
        access_token: current_user.token,
        auto_paginate: true
      )
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
        redirect_to repositories_path, notice: t('notices.repository_created')
      else
        render :new, status: :unprocessable_content
      end
    end
  end
end
