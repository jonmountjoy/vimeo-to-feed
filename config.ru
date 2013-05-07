STDOUT.sync = true

require 'bundler'
Bundler.require

use Rack::Static, :urls => ['/css', '/images', '/js'], :root => 'public'

require './app'
run App.new
