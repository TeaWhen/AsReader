# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'data_mapper'
require 'json'

config_file = File.new('conf.json', 'r')
config = JSON::parse(config_file.read, symbolize_names: true)
DataMapper::setup(:default, config[:mysql])

class User
  include DataMapper::Resource
  property :id, Serial

  property :name, String, :required => true
  property :dbid, String, :required => true, :unique => true
  property :access_token, String, :required => true
  property :refresh_token, String
end

DataMapper.finalize
DataMapper.auto_upgrade!
