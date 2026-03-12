# frozen_string_literal: true

class CommandRunner
  def self.run(command)
    require 'open3'
    stdout, = Open3.popen3(command) { |_i, o, _e, _t| [o.read] }
    stdout
  end
end
