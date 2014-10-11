require_relative "spec_helper"
require_relative "../split_sinatra_landingpage.rb"

def app
  SplitSinatraLandingpage
end

describe SplitSinatraLandingpage do
  it "responds with a welcome message" do
    get '/'

    last_response.body.must_include 'Welcome to the Sinatra Template!'
  end
end
