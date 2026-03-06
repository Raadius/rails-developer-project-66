# frozen_string_literal: true

module Web
  class HomeController < ApplicationController
    skip_after_action :verify_authorized

    def index; end
  end
end
