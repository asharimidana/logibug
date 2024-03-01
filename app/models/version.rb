class Version < ApplicationRecord
  belongs_to :project, class_name: 'Project', foreign_key: 'project_id', inverse_of: :versions
  has_many :test_cases, dependent: :destroy
  has_one :automatic, dependent: :destroy

  validates :name, presence: true

  def self.all_by_project_id(project_id = id, user_id = u_id)
    where(project_id:).joins(:project)
                      .merge(Project.joins(:members))
                      .merge(Member.where(user_id:, invite_confirmed: true))
  end

  def self.by_id(id_version, user_id)
    where(id: id_version).joins(:project)
                         .merge(Project.joins(:members))
                         .merge(Member.where(user_id:, invite_confirmed: true))
  rescue StandardError
    false
  end

  def self.po_qa?(id_version, user_id)
    project_id = Version.find(id_version)
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

  def version_att
    {
      "id": id,
      "name": name,
      "status": status,
      "project_id": project_id
    }
  end

  def version_clone
    {
      "id": id,
      "name": 'Copied of ' + name.to_s,
      "status": status,
      "project_id": project_id
    }
  end

  def clone_with_testcases
    cloned_version = dup
    cloned_version.id = nil
    cloned_version.save!

    test_cases.each do |testcase|
      cloned_testcase = testcase.dup
      cloned_testcase.version_id = cloned_version.id
      cloned_testcase.save!
    end

    cloned_version
  end
end
