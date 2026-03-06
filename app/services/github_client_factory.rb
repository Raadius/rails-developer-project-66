# frozen_string_literal: true

class GithubClientFactory
  def self.for_user(user)
    ApplicationContainer[:github_client].new(
      access_token: user.token,
      auto_paginate: true
    )
  end
end
