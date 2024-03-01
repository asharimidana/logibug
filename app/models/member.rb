class Member < ApplicationRecord
  belongs_to :user
  belongs_to :project
  belongs_to :role

  has_many :notifications, as: :recipient, dependent: :destroy
  has_noticed_notifications model_name: 'Notification'

  # ================new attr==============
  def invite_attr
    { id:, email: user.email }
  end

  def new_attr_role
    { id:, email: user.email, role: role.name }
  end

  def new_attr
    { id:, email: user.email }
  end

  def attr_notif
    {id:, project_id:, project_name: project.name, joined_user: user.name, message: "#{user.name} join this project as #{role.name}"}
  end

  def new_attribute
    {
      id:,
      email: user.email,
      role: role.name,
      status: invite_confirmed
    }
  end

  def update_by_token
    self.invite_confirmed = true
    save!(validate: false)
  rescue StandardError
    false
  end

  def update_by_role(role)
    role_id = Role.where(name: role)
    role_id = role_id[0][:id]
    self.role_id = role_id
    save!(validate: false)
  rescue StandardError
    false
  end

  # ======= self method =======
  def self.by_email_project(user_id, project_id)
    Member.where(user_id:, project_id:)
  rescue StandardError
    false
  end

  def self.all_by_project_id(project_id, user_id)
    cek_member = Member.where(project_id:, user_id:, invite_confirmed: true)
    Member.where(project_id:, invite_confirmed: true) if cek_member.present?
  rescue StandardError
    false
  end

  def self.add_member_po(project_id, user_id)
    role_name = Role.where(name: 'po')
    create!(user_id:, role_id: role_name[0][:id], project_id:, invite_confirmed: true)
  rescue StandardError
    nil
  end
end
