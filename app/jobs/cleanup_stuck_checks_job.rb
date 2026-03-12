# frozen_string_literal: true

class CleanupStuckChecksJob < ApplicationJob
  queue_as :default

  STUCK_THRESHOLD = 1.hour

  def perform
    Repository::Check
      .where(aasm_state: %w[pending running])
      .where('created_at < ?', STUCK_THRESHOLD.ago)
      .update_all(aasm_state: 'failed', passed: false)
  end
end
