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

      get new_repository_path

      assert_response :success
      assert_select 'option', text: 'rails/rails'
    end

    test '#create' do
      user = users(:two)
      sign_in(user)

      assert_difference('Repository.count') do
        post repositories_path, params: { repository: { github_id: 99_999 } }
      end

      created_repo = user.repositories.find_by(github_id: 99_999)
      assert { created_repo.name == 'rails' }
      assert { created_repo.user == user }
      assert_redirected_to repositories_path
    end
  end
end
