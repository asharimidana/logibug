class Project < ApplicationRecord
  has_many :members, class_name: 'Member', foreign_key: 'project_id', inverse_of: :project, dependent: :destroy
  has_many :users, through: :members
  has_many :versions, class_name: 'Version', foreign_key: 'project_id', inverse_of: :project, dependent: :destroy
  has_many :scenarios, dependent: :destroy
  has_many :roles, through: :members

  resourcify

  # validation on attribute name and description
  validates :name, presence: true
  validates :type_test, presence: true
  validates :platform, presence: true

  # enum for attribute type
  enum type_test: {
    manual: 0, automatic: 1
  }

  # enum for attribute platform
  enum platform: { mobile: 0, web: 1 }

  # Callback on project
  after_create :version_set

  def self.all_by_member_id(member_id = id, user_id = u_id)
    where(member_id).joins(:members).merge(Member.where(user_id:, invite_confirmed: true))
  end

  def self.by_project_id(project_id, user_id)
    Project.joins(:members).merge(Member.where(user_id:, project_id:, invite_confirmed: true))
  rescue StandardError
    false
  end

  def self.po(project_id, user_id)
    member_get = Member.where(user_id:, project_id:, invite_confirmed: true)
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
    end
    # rescue StandardError
    #   false
  end

  def self.project_by_member(user_id)
    joins("INNER JOIN members ON members.user_id=#{user_id} AND members.project_id=projects.id")
  rescue StandardError
    nil
  end
  
  def project_all
    {
      id:,
      name:,
      type_test:,
      platform:
    }
  end

  def project_att
    {
      "id": id,
      "name": name,
      "type_test": type_test,
      "platform": platform
    }
  end

  # Tampil data ke Scenario
  def project_scenario
    {
      "id": id,
      "name": name
    }
  end

  def self.find_member
    Member.find_by_id([:id])
  end

  def version_set
    versions.create!(name: 'Version 1 ' + name.to_s)
  end
end
