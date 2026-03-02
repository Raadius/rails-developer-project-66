# frozen_string_literal: true

class RepositoryService
  REPO_DIR = Rails.root.join('tmp/repos')
  class << self
    def update_info_from_github(repository)
      client = ApplicationContainer[:github_client].new(
        access_token: repository.user.token,
        auto_paginate: true
      )

      repository_info = client.repository(repository.github_id.to_i)
      repository.update!(
        name: repository_info.name,
        full_name: repository_info.full_name,
        language: repository_info.language&.downcase,
        clone_url: repository_info.clone_url,
        ssh_url: repository_info.ssh_url
      )
    end

    def check_repository(check)
      check.run!

      repo = check.repository
      client = ApplicationContainer[:github_client].new(
        access_token: repo.user.token,
        auto_paginate: true
      )
      # получаем последний коммит
      commit_sha = client.commits(repo.full_name).first.sha
      check.update!(commit_id: commit_sha)

      # клонируем репо во временную папку
      dest = REPO_DIR.join(check.id.to_s)
      FileUtils.mkdir_p(dest)
      system("git clone #{repo.clone_url} #{dest}")

      # запускаем линтер
      linter = ApplicationContainer[:linter]
      result = linter.run(dest)

      check.update!(
        issues_count: result.dig('summary', 'offense_count'),
        linter_output: result.to_json
      )
      check.finish!
    rescue StandardError => e
      check.fail!
      Rails.logger.error(e)
    ensure
      # чистим временную папку
      FileUtils.rm_rf(REPO_DIR.join(check.id.to_s)) if check.id
    end
  end
end
