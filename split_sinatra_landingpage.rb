class SplitSinatraLandingpage < Sinatra::Base
  enable :sessions
  helpers Split::Helper

  set :public_folder => "public", :static => true

  get "/" do
    erb :index
  end
end
