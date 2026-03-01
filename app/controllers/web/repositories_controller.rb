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
    end

    def new
      client = Octokit::Client.new(access_token: current_user.token, auto_paginate: true)

      languages = Repository.language.values
      github_repos = client.repos(user: current_user.nickname)
      @github_repositories = github_repos.select { |rep| languages.include?(rep.language&.downcase) }
      @repository = current_user.repositories.build
    end

    def create
      @repository = current_user.repositories.find_or_initialize_by(repository_params)

      if @repository.save
        redirect_to repositories_path, notice: t('notices.repository_created')
      else
        render :new, status: :unprocessable_content, error: @repository.errors.full_messages.join('\n')
      end
    end

    private

    def repository_params
      params.require(:repository).permit(:github_id, :name, :full_name, :language, :clone_url, :ssh_url)
    end
  end
end
