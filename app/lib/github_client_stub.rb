# frozen_string_literal: true

class GithubClientStub
  RepoStub = Struct.new(:id, :name, :language, :full_name, :clone_url, :ssh_url)
  CommitStub = Struct.new(:sha)

  def initialize(**_args); end

  def repository(_github_id)
    RepoStub.new(
      id: 8514,
      name: 'rails',
      language: 'ruby',
      full_name: 'rails/rails',
      clone_url: 'https://github.com/rails/rails.git',
      ssh_url: 'git@github.com:rails/rails.git'
    )
  end

  def repos(**_args)
    [
      RepoStub.new(
        id: 8514,
        name: 'rails',
        language: 'Ruby',
        full_name: 'rails/rails',
        clone_url: 'https://github.com/rails/rails.git',
        ssh_url: 'git@github.com:rails/rails.git'
      )
    ]
  end

  def commits(_full_name)
    [CommitStub.new('abc123def456')]
  end

  def create_hook(_full_name, _type, _config, _options = {}); end
end
