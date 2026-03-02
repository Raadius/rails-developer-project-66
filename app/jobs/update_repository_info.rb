# frozen_string_literal: true

class UpdateRepositoryInfo < ApplicationJob
  queue_as :default

  def perform(repository_id)
    repository = Repository.find(repository_id)
    RepositoryService.update_info_from_github(repository)
  end
end
