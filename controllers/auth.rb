module Auth
  def user
    AppEngine::Users.current_user
  end
  def authorize only_admin = true
    unless (user && only_admin ? AppEngine::Users.admin? : true)
      redirect AppEngine::Users.create_login_url(request.url)
    end  
  end
end