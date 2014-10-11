# Load path and gems/bundler
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require "bundler"
Bundler.require

# Local config
require "find"

%w{config/initializers lib}.each do |load_path|
  Find.find(load_path) { |f|
    require f unless f.match(/\/\..+$/) || File.directory?(f)
  }
end

# Load app
require "split_sinatra_landingpage"
run SplitSinatraLandingpage

require 'split/dashboard'

# Split::Dashboard.use Rack::Auth::Basic do |username, password|
#   username == 'admin' && password == 'password'
# end

run Rack::URLMap.new \
  "/"       => SplitSinatraLandingpage.new,
  "/split" => Split::Dashboard.new
