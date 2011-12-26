require 'sinatra/base'
require 'lib/hostess/app'

map "/" do
  run Hostess::App
end

