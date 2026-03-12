# frozen_string_literal: true

class Linter
  RUBOCOP_CONFIG = Rails.root.join('.rubocop.yml').to_s

  def self.run(path, config: RUBOCOP_CONFIG)
    rubocop = Gem.bin_path('rubocop', 'rubocop')
    command = "#{rubocop} --format json --config #{config} #{path}"
    stdout = ApplicationContainer[:command_runner].run(command)
    JSON.parse(stdout)
  end
end
