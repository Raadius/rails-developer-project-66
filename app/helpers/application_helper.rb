# frozen_string_literal: true

module ApplicationHelper
  def github_commit_url(repository, commit_id)
    "https://github.com/#{repository.full_name}/commit/#{commit_id}"
  end

  def github_file_url(repository, commit_id, path)
    "https://github.com/#{repository.full_name}/blob/#{commit_id}/#{path}"
  end

  def flash_class(type)
    case type
    when 'notice'
      'alert-success'
    when 'alert'
      'alert-danger'
    else
      'alert-info'
    end
  end
end
