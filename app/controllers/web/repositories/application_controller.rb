# frozen_string_literal: true

module Web
  module Repositories
    class ApplicationController < Web::ApplicationController
      def repository
        @repository ||= Repository.find(params[:repository_id])
      end
    end
  end
end
