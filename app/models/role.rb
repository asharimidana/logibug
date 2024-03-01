class Role < ApplicationRecord
  has_many :members, dependent: :destroy
  belongs_to :resource, polymorphic: true, optional: true
  validates :name, presence: true, uniqueness: true

  def self.by_name(name)
    Role.where(name:)
  rescue StandardError
    false
  end

  def self.by_project_id(project_id, user_id)
    member = Member.where(project_id:, user_id:, invite_confirmed: true)
    role = Role.where(id: member[0].role_id)
    role.first.name
  rescue StandardError
    false
  end

  def self.all_by_project_id(project_id, user_id)
    Member.where(project_id:, user_id:)
  rescue StandardError
    false
  end
end
