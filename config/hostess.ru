require 'sinatra/base'
require 'hostess/app'

map "/" do
  run Hostess::App
end

