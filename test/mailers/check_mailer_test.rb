# frozen_string_literal: true

require 'test_helper'

class CheckMailerTest < ActionMailer::TestCase
  test 'failed sends email with check details' do
    check = repository_checks(:one)
    check.update!(status: 'finished', issues_count: 3)

    mail = CheckMailer.failed(check)

    assert_emails 1 do
      mail.deliver_now
    end

    assert_equal [check.repository.user.email], mail.to
    assert_match check.repository.full_name, mail.subject
    assert_match check.repository.user.nickname, mail.body.encoded
    assert_match '3', mail.body.encoded
  end
end
