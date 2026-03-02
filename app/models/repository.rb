# frozen_string_literal: true

class Repository < ApplicationRecord
  extend Enumerize

  belongs_to :user
  has_many :checks, class_name: 'Repository::Check', dependent: :destroy

  enumerize :language, in: %w[ruby], default: 'ruby'

  validates :github_id, :name, :full_name, presence: true
  validates :github_id, uniqueness: { scope: :user_id }
end
