# frozen_string_literal: true

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register :github_client, -> { GithubClientStub }
    register :linter, -> { LinterStub }
    register :git, -> { GitStub }
  else
    register :linter, -> { Linter }
    register :git, -> { Git }
    register :github_client, -> { Octokit::Client }
  end
end
