module AuthorizationUserId
  def self.auth(current_user, params_user)
    current_user.id.to_s == params_user
  end
end
