# frozen_string_literal: true

class Linter
  RUBOCOP_CONFIG = Rails.root.join('.rubocop.yml').to_s

  def self.run(path, config: RUBOCOP_CONFIG)
    require 'open3'

    command = "rubocop --format json --config #{config} #{path}"
    stdout, _status = Open3.popen3(command) do |_stdin, stdout, _stderr, wait_thr|
      [stdout.read, wait_thr.value]
    end
    JSON.parse(stdout)
  end
end
