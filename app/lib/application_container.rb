# frozen_string_literal: true

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register :github_client,     -> { GithubClientStub }
    register :ruby_linter,       -> { LinterStub }
    register :javascript_linter, -> { JsLinterStub }
    register :git,               -> { GitStub }
  else
    register :ruby_linter,       -> { Linter }
    register :javascript_linter, -> { JsLinter }
    register :git,               -> { Git }
    register :github_client,     -> { Octokit::Client }
  end
end
