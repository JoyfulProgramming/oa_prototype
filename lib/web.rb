require 'sinatra'

class Web < Sinatra::Base
  get '/' do
    'hello world from web env: ' + App.env.to_s
  end
end


