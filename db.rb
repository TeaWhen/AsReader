# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'data_mapper'
require 'json'

config_file = File.new('conf.json', 'r')
config = JSON::parse(config_file.read, symbolize_names: true)
DataMapper::setup(:default, config[:mysql])

class School
  include DataMapper::Resource
  property :id, Serial

  property :username, String, :required => true, :unique => true
  property :password, BCryptHash, :required => true
  property :school_name, String, :required => true

  has n, :teachers
end

class Teacher
  include DataMapper::Resource
  property :id, Serial

  property :name, String, :required => true
  property :subject, String, :required => true
  property :gender, String
  property :age, String

  belongs_to :school
end

class Question
  include DataMapper::Resource
  property :id, Serial

  property :description, String, :required => true
end

DataMapper.finalize
DataMapper.auto_upgrade!
