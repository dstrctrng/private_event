module Hostess 
  class App < Sinatra::Base
    enable :raise_errors
    disable :show_exceptions

    def serve
      send_file(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'server', 'repo', request.path_info)))
    end

    %w[/specs.4.8.gz
      /latest_specs.4.8.gz
      /prerelease_specs.4.8.gz
    ].each do |index|
      get index do
        content_type('application/x-gzip')
        serve
      end
    end

    get "/quick/Marshal.4.8/*.gemspec.rz" do
      content_type('application/x-deflate')
      serve
    end

    get "/gems/*.gem" do
      serve
    end

    def full_name
      @full_name ||= params[:splat].join.chomp('.gem')
    end
  end
end

