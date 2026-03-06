# frozen_string_literal: true

class RepositoryCheckService
  REPO_DIR = Rails.root.join('tmp/repos')

  def initialize(check)
    @check = check
    @repo = check.repository
    @client = GithubClientFactory.for_user(@repo.user)
    @linter = ApplicationContainer[:"#{@repo.language}_linter"]
    @git = ApplicationContainer[:git]
  end

  def call
    @check.run!

    commit_sha = @client.commits(@repo.full_name).first.sha
    @check.update!(commit_id: commit_sha)

    clone_and_lint

    @check.finish!
    CheckMailer.notify(@check).deliver_later unless @check.checking_passed?
  rescue StandardError => e
    @check.fail!
    Rails.logger.error(e)
    CheckMailer.notify(@check).deliver_later
  ensure
    FileUtils.rm_rf(repo_dest) if @check.id
  end

  private

  def clone_and_lint
    FileUtils.mkdir_p(repo_dest)
    @git.clone(@repo.clone_url, repo_dest)

    result = @linter.run(repo_dest)
    @check.update!(
      issues_count: result.dig('summary', 'offense_count'),
      linter_output: result.to_json
    )
  end

  def repo_dest
    @repo_dest ||= REPO_DIR.join(@check.id.to_s)
  end
end
