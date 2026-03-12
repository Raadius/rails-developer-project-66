# frozen_string_literal: true

class JsLinter
  ESLINT = Rails.root.join('node_modules/.bin/eslint').to_s
  CONFIG = Rails.root.join('.eslintrc.yml').to_s

  def self.run(path)
    command = "#{ESLINT} --no-eslintrc --config #{CONFIG} --format json #{path}"
    stdout = ApplicationContainer[:command_runner].run(command)
    normalize(JSON.parse(stdout))
  end

  def self.normalize(eslint_output)
    files = eslint_output.map do |file|
      offenses = file['messages'].map do |msg|
        {
          'message' => msg['message'],
          'cop_name' => msg['ruleId'],
          'location' => { 'line' => msg['line'], 'column' => msg['column'] }
        }
      end
      { 'path' => file['filePath'], 'offenses' => offenses }
    end

    offense_count = files.sum { |f| f['offenses'].length }
    { 'summary' => { 'offense_count' => offense_count }, 'files' => files }
  end
end
