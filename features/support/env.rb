require 'rubygems'
require 'bundler/setup'
require 'daitss/archive'

require 'ruby-debug'

raise "path to core repository not set in environment variable PATH_TO_CORE" unless ENV["PATH_TO_CORE"]
path_to_core = ENV["PATH_TO_CORE"]

app_file = File.join path_to_core, "app.rb"
require app_file

# Force the application name because polyglot breaks the auto-detection logic.
Sinatra::Application.app_file = app_file
Sinatra::Application.set :environment, :test

require 'net/http'
require 'spec/expectations'
require 'rack/test'
require 'webrat'
require 'nokogiri'

require 'daitss/model'
require 'daitss/archive'

Webrat.configure { |config| config.mode = :rack }

class MyWorld
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers

  Webrat::Methods.delegate_to_session :response_code, :response_body

  def app
    Sinatra::Application
  end

  def fixture name
    File.join File.dirname(__FILE__), '..', 'fixtures', name
  end

  def sip name
    if File.directory? File.join(File.dirname(__FILE__), '..', 'fixtures', name)
      File.join File.dirname(__FILE__), '..', 'fixtures', name
    elsif File.directory? File.join(ENV["AUX_SIP_PATH"], name)
      File.join ENV["AUX_SIP_PATH"], name
    else
      raise "Package #{name} wasn't found in fixtures or #{ENV['AUX_SIP_PATH']}"
    end

  end

  def sip_tarball name
    path = sip name
    tar = %x{tar -c -C #{File.dirname path} -f - #{File.basename path} }
    raise "tar did not work" if $?.exitstatus != 0
    tar
  end

  def sips
    @sips ||= []
  end

  def submit name
    a = Archive.new
    zip_path = fixture name
    package = a.submit zip_path, Operator.get('root')
    raise "test submit failed for #{name}:\n\n#{package.events.last.notes}" if package.events.first :name => 'reject'
    sips << { :sip => package.sip.name, :wip => package.id }
    a.workspace[package.id]
  end

  def empty_out_workspace
    ws = Archive.new.workspace

    ws.each do |wip|
      wip.stop if wip.running?
      FileUtils.rm_r wip.path
    end

  end

end

World{MyWorld.new}

Before do
  Daitss::CONFIG.load_from_env
  Archive.create_work_directories
  Archive.setup_db

  $cleanup = []
end

