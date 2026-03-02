class AddLinterOutputToRepositoryChecks < ActiveRecord::Migration[7.2]
  def change
    add_column :repository_checks, :linter_output, :text
  end
end
