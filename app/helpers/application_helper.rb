# frozen_string_literal: true

module ApplicationHelper
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
