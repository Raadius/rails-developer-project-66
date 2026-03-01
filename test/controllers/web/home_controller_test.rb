# frozen_string_literal: true

require 'test_helper'

module Web
  class HomeControllerTest < ActionDispatch::IntegrationTest
    test '#home' do
      get root_path
      assert_response :success
    end

    test '#home page content' do
      get root_path
      assert_response :success

      assert_match I18n.t('titles.hexlet_hello'), response.body
      assert_match I18n.t('titles.project'), response.body
    end

    test '#home user anonimus' do
      get root_path
      assert_response :success

      assert_match I18n.t('layout.head.navbar.sign_in'), response.body
      assert_no_match I18n.t('layout.head.navbar.logout'), response.body
    end

    test '#home user logged in' do
      @user = users(:one)
      sign_in(@user)

      get root_path

      assert_match @user.email, response.body
      assert_match I18n.t('layout.head.navbar.logout'), response.body
      assert_no_match I18n.t('layout.head.navbar.sign_in'), response.body
    end
  end
end
