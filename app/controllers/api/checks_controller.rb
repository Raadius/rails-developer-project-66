# frozen_string_literal: true

module Api
  class ChecksController < Api::ApplicationController
    def create
      payload = JSON.parse(request.body.read)
      github_id = payload.dig('repository', 'id')

      repository = Repository.find_by(github_id: github_id)
      return head :unprocessable_content unless repository

      check = repository.checks.create!
      ::RepositoryCheckJob.perform_later(check.id)

      head :ok
    end
  end
end
