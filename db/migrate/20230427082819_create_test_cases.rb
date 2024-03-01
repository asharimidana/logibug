class CreateTestCases < ActiveRecord::Migration[7.0]
  def change
    create_table :test_cases do |t|
      t.integer :test_category
      t.string :pre_condition
      t.string :testcase
      t.text :test_step
      t.string :expectation
      t.integer :version_id
      t.integer :scenario_id

      t.timestamps
    end
  end
end
