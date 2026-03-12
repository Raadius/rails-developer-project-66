# frozen_string_literal: true

class RepositoryCheckService
  REPO_DIR = Rails.root.join('tmp/repos')

  def self.call(check)
    repo   = check.repository
    client = GithubClientFactory.for_user(repo.user)
    linter = ApplicationContainer[:"#{repo.language}_linter"]
    git    = ApplicationContainer[:git]

    check.run!

    commit_sha = client.commits(repo.full_name).first.sha
    check.update!(commit_id: commit_sha)

    clone_and_lint(check, repo, linter, git)

    check.update!(passed: check.checking_passed?)
    check.finish!
    CheckMailer.notify(check).deliver_later unless check.checking_passed?
  rescue StandardError => e
    check.update!(passed: false)
    check.fail!
    Rails.logger.error(e)
    CheckMailer.notify(check).deliver_later
  ensure
    FileUtils.rm_rf(repo_dest(check)) if check.id
  end

  def self.clone_and_lint(check, repo, linter, git)
    dest = repo_dest(check)
    FileUtils.mkdir_p(dest)
    git.clone(repo.clone_url, dest)

    result = linter.run(dest)
    check.update!(
      issues_count: result.dig('summary', 'offense_count'),
      linter_output: result.to_json
    )
  end
  private_class_method :clone_and_lint

  def self.repo_dest(check)
    REPO_DIR.join(check.id.to_s)
  end
  private_class_method :repo_dest
end
