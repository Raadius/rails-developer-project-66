# frozen_string_literal: true

class Repository::Check < ApplicationRecord
  include AASM

  belongs_to :repository

  aasm column: :status do
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

    JSON.parse(linter_output)
        .fetch('files', [])
        .select { |f| f['offenses'].present? }
  end
end
