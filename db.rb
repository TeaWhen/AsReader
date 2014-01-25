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

  property :username, String, :required => true, :unique => true
  property :name, String
  property :token, String, :required => true
end

DataMapper.finalize
DataMapper.auto_upgrade!
