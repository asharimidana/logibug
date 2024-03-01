class Result < ApplicationRecord
  belongs_to :test_case

  validates :actual, presence: true
  validates :status, presence: true
  validates :priority, presence: true
  validates :severity, presence: true
  # validates :img_url, presence: true
  # validates :note, presence: true

  has_many :notifications, as: :recipient, dependent: :destroy
  # after_update_commit :notify_recipient
  # before_destroy :cleaup_notifications
  has_noticed_notifications model_name: 'Notification'


  def new_attr_create_fail(u_id)
    {id:, test_case_id:, priority:, severity:, created_by: User.find(u_id).id, message: "#{User.find(u_id).name} added #{priority} and  #{severity} status"}
  end

  def new_attr_create_pass(u_id)
    {id:, test_case_id:, status:, created_by: User.find(u_id).id, message: "#{User.find(u_id).name} added #{status} status"}
  end
  
  def new_attr_update(u_id, current_status)
    {id:, test_case_id:, prev_status: current_status ,status: , change_by: User.find(u_id).id, message: "#{User.find(u_id).name} has changed the #{current_status} status to #{status}"}
  end



  def self.all_by_test_case_id(test_case_id = id, user_id = u_id)
    joins(:test_case).where(test_case_id:)
                      .merge(TestCase.joins(:version))
                      .merge(Version.joins(:project))
                      .merge(Project.joins(:members))
                      .merge(Member.where(user_id:, invite_confirmed: true))
  rescue StandardError
    false
  end

  def self.by_id(result_id = id, user_id = u_id)
    
    joins(:test_case).where(id: result_id)
                      .merge(TestCase.joins(:version))
                      .merge(Version.joins(:project))
                      .merge(Project.joins(:members))
                      .merge(Member.where(user_id:, invite_confirmed: true))
  rescue StandardError
    false
  end

  def self.po_qa?(id_test_case, user_id)    
    member = Member.where(user_id:).joins(:project)
                            .merge(Project.joins(:versions))
                            .merge(Version.joins(:test_cases))
                            .merge(TestCase.where(id: id_test_case))
   
    false unless member.present?
    role = Role.find(member[0][:role_id])
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

  def get_user_test_case
    User.joins(members: {project: {scenarios: :test_cases}}).where("test_cases.id = ?",test_case_id)
  end


  enum status:{
    fail: 0,
    pass: 1
    }

    enum priority:{ 
      low: 0,
      medium: 1,
      high: 2,
      urgent: 3
      }

  enum severity:{
    low_severity: 0,
    minor: 1,
    major: 2,
    critical: 3
    }


  def result_att
    {
      id: id,
      test_case_id: test_case_id,
      actual: actual,
      status: status,
      priority: priority,
      severity: severity,
      img_url: img_url,
      note: note,
      user_name: user_name,
    }
  end

  def result_new_att(user_id)
    {
      id: id,
      status: status,
      created_by: User.find_by(id: user_id).name,
    }
  end

  private
  def cleaup_notifications
    notifications_as_result.destroy.all
  end

  def notify_recipient()
    project_id = self.test_case.version.project_id
    puts
    query = User.joins(:members).where(members: { project_id: project_id }).where.not(id: u_id)
    notification = UpdatedResultNotification.with(
      changed_by: user.name, result: self
    )
    notification.deliver_later(query)
  end
end
