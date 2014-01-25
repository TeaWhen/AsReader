# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'haml'
require 'json'
require 'sinatra/json'

config_file = File.new('conf.json', 'r')
set :config, JSON::parse(config_file.read, symbolize_names: true)

get '/' do
  haml :index
end
