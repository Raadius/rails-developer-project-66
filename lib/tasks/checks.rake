# frozen_string_literal: true

namespace :checks do
  desc 'Mark stuck pending/running checks as failed'
  task cleanup_stuck: :environment do
    CleanupStuckChecksJob.perform_now
  end
end
