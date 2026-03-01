# frozen_string_literal: true

require 'test_helper'

module Web
  class RepositoriesControllerTest < ActionDispatch::IntegrationTest
    test '#index' do
      user = users(:one)
      sign_in(user)

      assert signed_in?

      get repositories_path
      assert_response :success
    end

    test '#show' do
      user = users(:one)
      sign_in(user)

      repo = repositories(:rails_rails)
      get repository_path(repo)

      assert_response :success
      assert_match repo.name, response.body
      assert_match repo.full_name, response.body
    end

    test '#new' do
      user = users(:two)
      sign_in(user)

      mock_repos = [
        OpenStruct.new(
          id: 12345,
          name: 'test-repo',
          full_name: "#{user.nickname}/test-repo",
          language: 'Ruby',
          clone_url: "https://github.com/#{user.nickname}/test-repo.git",
          ssh_url: "git@github.com:#{user.nickname}/test-repo.git"
        )
      ]

      mock_client = Minitest::Mock.new
      mock_client.expect(:repos, mock_repos, [], user: user.nickname)

      Octokit::Client.stub(:new, mock_client) do
        get new_repository_path
      end

      assert_response :success
      assert_match "#{user.nickname}/test-repo", response.body
      assert_select 'option', text: "#{user.nickname}/test-repo"
    end

    test '#create' do
      user = users(:two)
      sign_in(user)

      repo_params = {
        github_id: 99999,
        name: 'my-project',
        full_name: "#{user.nickname}/my-project",
        language: 'ruby',
        clone_url: "https://github.com/#{user.nickname}/my-project.git",
        ssh_url: "git@github.com:#{user.nickname}/my-project.git"
      }

      assert_difference('Repository.count') do
        post repositories_path, params: { repository: repo_params }
      end

      created_repo = Repository.find_by(github_id: repo_params[:github_id])
      assert { created_repo.name == repo_params[:name] }
      assert { created_repo.user == user }
      assert_redirected_to repositories_path
    end
  end
end