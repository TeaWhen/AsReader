# encoding: utf-8

require_relative 'db'

require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/cookies'
require 'sinatra/json'
require 'haml'
require 'json'
require 'httparty'

config_file = File.new('conf.json', 'r')
set :config, JSON::parse(config_file.read, symbolize_names: true)

get '/' do
  haml :index
end

get '/login/github/?' do
  redirect "https://github.com/login/oauth/authorize?client_id=#{settings.config[:github][:client_id]}"
end

get '/login_callback/github/?' do
  resp = HTTParty.post("https://github.com/login/oauth/access_token?client_id=#{settings.config[:github][:client_id]}&client_secret=#{settings.config[:github][:client_secret]}&code=#{params[:code]}",
    :headers => {"Accept"=> "application/json"})
  info = JSON::parse(resp.body, symbolize_names: true)
  u = User.first(token: info[:access_token])
  unless u
    user_resp = HTTParty.get("https://api.github.com/user?access_token=#{info[:access_token]}", :headers => {"User-Agent" => "AsReader"})
    user_info  = JSON::parse(user_resp.body, symbolize_names: true)
    user = User.new
    user.username = user_info[:login]
    user.name = user_info[:name]
    user.token = info[:access_token]
    user.save
    u = user
  end
  cookies[:login] = u.username
  redirect '/home/'
end

get '/home/?' do
  u =  User.first(username: cookies[:login])
  return "Welcome, #{u.name}"
end
