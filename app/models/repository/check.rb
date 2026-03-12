# frozen_string_literal: true

class Repository::Check < ApplicationRecord
  include AASM

  belongs_to :repository

  scope :recent, -> { order(created_at: :desc) }
  scope :completed, -> { where(aasm_state: %w[finished failed]) }

  aasm do
    state :pending, initial: true
    state :running
    state :finished
    state :failed

    event :run do
      transitions from: :pending, to: :running
    end

    event :finish do
      transitions from: :running, to: :finished
    end

    event :fail do
      transitions from: :running, to: :failed
    end
  end

  def checking_passed?
    finished? && issues_count&.zero?
  end

  def linter_offenses
    return [] if linter_output.blank?

    @linter_offenses ||= JSON.parse(linter_output)
                             .fetch('files', [])
                             .select { |f| f['offenses'].present? }
  end
end
