require 'sinatra'

get '/' do
  'hello world from web env: ' + App.env.to_s
end

