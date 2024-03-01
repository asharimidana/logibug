class TestCase < ApplicationRecord
  # Relasi
  belongs_to :scenario
  belongs_to :version
  has_one :result, dependent: :destroy

  # has_many :notifications, through: :user, dependent: :destroy
  # has_noticed_notifications model_name: 'Notification'

  # Validasi
  validates :test_category, presence: true
  validates :pre_condition, presence: true
  validates :testcase, presence: true
  validates :test_step, presence: true
  validates :expectation, presence: true

  def self.all_by_version_id(version_id = id, user_id = u_id)
    joins(:version).where(version_id:)
                   .merge(Version.joins(:project))
                   .merge(Project.joins(:members))
                   .merge(Member.where(user_id:, invite_confirmed: true))
  rescue StandardError
    false
  end

  # get data by id
  def self.by_id(id_test_case, user_id)
    joins(:version).where(id: id_test_case)
                   .merge(Version.joins(:project))
                   .merge(Project.joins(:members))
                   .merge(Member.where(user_id:, invite_confirmed: true))
  rescue StandardError
    false
  end

  enum test_category: {
    positif: 1,
    negatif: 2
  }

  # Show Data
  def new_attributes
    {
      id:,
      version_id: version.id,
      scenario_id: scenario.id,
      scenario_name: scenario.name,
      project_id: scenario.project_id,
      test_category:,
      pre_condition:,
      testcase:,
      test_step:,
      expectation:,
      status: (result.status unless result.nil?)
    }
  end

  def count_test
    # result_count =Testcase.joins(:result).count
    result_count == 100

    if result_count == 0 && result_count == 199
      puts 'Beginner'
    elsif
      result_count == 200 && result_count == 999
      puts 'Intermediate'
    elsif result_count == 1000 && result_count == 1999
      puts 'Advanced'
    else
      puts 'Mastery'
    end
  end
end
