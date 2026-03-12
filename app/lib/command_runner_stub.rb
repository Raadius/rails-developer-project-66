# frozen_string_literal: true

class CommandRunnerStub
  def self.run(command)
    if command.include?('eslint')
      '[]'
    else
      '{"summary":{"offense_count":0},"files":[]}'
    end
  end
end
