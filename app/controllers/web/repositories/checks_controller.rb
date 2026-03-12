# frozen_string_literal: true

module Web
  module Repositories
    class ChecksController < Repositories::ApplicationController
      before_action :check_auth!

      def show
        @check = repository.checks.find(params[:id])
        authorize @check
      end

      def create
        if repository.checks.exists?(aasm_state: %w[pending running])
          redirect_to repository_path(repository), notice: t('notices.check_already_running')
          return
        end

        check = repository.checks.create!
        RepositoryCheckJob.perform_later(check.id)

        redirect_to repository_path(repository), notice: t('notices.check_started')
      end
    end
  end
end
