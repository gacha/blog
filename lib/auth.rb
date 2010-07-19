module Auth

  get '/logout/' do
    redirect AppEngine::Users.create_logout_url("/")
  end

  def current_user
    AppEngine::Users.current_user
  end

  def admin?
    AppEngine::Users.admin?
  end

  def authorize only_admin = true
    unless current_user && (only_admin ? admin? : true)
      redirect AppEngine::Users.create_login_url(request.url)
    end  
  end
  
end