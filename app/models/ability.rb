class Ability
  include CanCan::Ability

  def initialize(user, role)
    # can :manage, :all

    # return unless user

    # can %i[read update], Project, user

    # return unless user.admin?

    # can :manage, Article
    # Define abilities for the user here. For example:
    #
    # if true
    #   can :manage, :all
    # else

    # can :manage, :all
    return unless user == true

    can :read, Project

    return unless role == 'po'

    can :write, Project
    # can :manage, Project
    # end

    #
    #
    #
    #
    # def cek_role?(_idd = 1, _data = 'xx')
    #   if _idd == 1 && _data == 'xx'
    #     true
    #   else
    #     false
    #   end
    # end
    #
    #
    #
    #
    #   return unless user.present?
    #   can :read, :all
    #   return unless user.admin?
    #   can :manage, :all
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, published: true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
  end
end
