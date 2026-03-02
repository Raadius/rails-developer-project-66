# frozen_string_literal: true

require 'test_helper'

module Web
  module Repositories
    class ChecksControllerTest < ActionDispatch::IntegrationTest
      test '#create creates a check and enqueues job' do
        user = users(:one)
        sign_in(user)

        repo = repositories(:rails_rails)

        assert_difference('Repository::Check.count') do
          assert_enqueued_with(job: RepositoryCheckJob) do
            post repository_checks_path(repo)
          end
        end

        assert_redirected_to repository_path(repo)
      end

      test '#show' do
        user = users(:one)
        sign_in(user)

        repo = repositories(:rails_rails)
        check = repository_checks(:one)

        get repository_check_path(repo, check)

        assert_response :success
        assert_match check.commit_id, response.body
      end
    end
  end
end
