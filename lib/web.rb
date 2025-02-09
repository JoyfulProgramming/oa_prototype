require 'sinatra'

class Web < Sinatra::Base
  get '/' do
    'hello world'
  end
end


