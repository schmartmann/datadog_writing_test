require 'sinatra/activerecord'
require './config/environment'
require "sinatra/reloader"
current_dir = Dir.pwd
Dir["#{current_dir}/models/*.rb"].each { |file| require file }
require 'ddtrace'
require 'ddtrace/contrib/sinatra/tracer'

class Sinatra::Application

  configure :development do
    register Sinatra::Reloader
  end

  configure do
    settings.datadog_tracer.configure default_service: 'my-app', debug: true, enabled: true
  end

  get "/" do
    @dogs = Dog.all
    erb :index
  end

end
