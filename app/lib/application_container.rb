# frozen_string_literal: true

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register :github_client,   -> { GithubClientStub }
    register :command_runner,  -> { CommandRunnerStub }
    register :git,             -> { GitStub }
  else
    register :command_runner,  -> { CommandRunner }
    register :git,             -> { Git }
    register :github_client,   -> { Octokit::Client }
  end

  register :ruby_linter,       -> { Linter }
  register :javascript_linter, -> { JsLinter }
end
