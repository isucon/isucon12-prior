require 'sinatra/base'

class App < Sinatra::Base
  configure do
    set :sessions, key: 'isucon12_prior', expire_after: 3600
    set :session_secret, 'tagomoris'
    set :public_folder, './public'
  end

  configure :development do
    enable :logging
  end

  get '*' do
    File.read(File.join('public', 'index.html'))
  end
end
