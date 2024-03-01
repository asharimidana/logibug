class Scenario < ApplicationRecord
  # Relasi
  belongs_to :project
  has_many :test_cases

  # Validasi
  validates :project_id, presence: true
  validates :name, presence: true

  def self.all_by_project_id(project_id = id, user_id = u_id)
    where(project_id:).joins(:project)
                      .merge(Project.joins(:members))
                      .merge(Member.where(user_id:, invite_confirmed: true))
  rescue StandardError
    false
  end

  # get data by id
  def self.by_id(id_scenario, user_id)
    where(id: id_scenario).joins(:project)
                          .merge(Project.joins(:members))
                          .merge(Member.where(user_id:, invite_confirmed: true))
  rescue StandardError
    false
  end

  def self.find_by_project_id(project_id = id, user_id = u_id)
    member_get = Member.where(user_id:, project_id:)
    false unless member_get.present?
    role = Role.find(member_get[0][:role_id])
    data = role[:name]
    case data
    when 'po'
      'po'
    when 'qa'
      'qa'
    when 'dev'
      'dev'
    else
      'other'
    end
  rescue StandardError
    false
  end

  def self.po_qa?(id_scenario, user_id)
    project_id = Scenario.find(id_scenario)
    member_get = Member.where(user_id:, project_id: project_id[:project_id])
    false unless member_get.present?
    role = Role.find(member_get[0][:role_id])
    data = role[:name]
    case data
    when 'po'
      'po'
    when 'qa'
      'qa'
    when 'dev'
      'dev'
    else
      'other'
    end
  rescue StandardError
    false
  end

  # Show Data
  def new_attributes
    {
      id:,
      project_id:,
      name:
    }
  end
end
