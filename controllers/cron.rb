module CronController
  include Auth
  
  get '/cron/:name' do
    #authorize
    Cron::run params[:name]
    "Done"
  end
end
