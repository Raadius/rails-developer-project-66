# frozen_string_literal: true

require 'test_helper'

module Api
  class ChecksControllerTest < ActionDispatch::IntegrationTest
    test '#create creates check, runs job, check passes' do
      repo = repositories(:rails_rails)
      payload = { repository: { id: repo.github_id } }.to_json

      perform_enqueued_jobs do
        assert_difference('Repository::Check.count') do
          post api_checks_path,
               params: payload,
               headers: { 'Content-Type' => 'application/json' }
        end
      end

      assert_response :ok

      check = repo.checks.last
      assert check.finished?
      assert check.checking_passed?
    end

    test '#create returns unprocessable_entity for unknown repository' do
      payload = { repository: { id: 0 } }.to_json

      post api_checks_path,
           params: payload,
           headers: { 'Content-Type' => 'application/json' }

      assert_response :unprocessable_entity
    end
  end
end
