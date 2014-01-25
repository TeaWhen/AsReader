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

get '/login/douban/?' do
  redirect "https://www.douban.com/service/auth2/auth?client_id=#{settings.config[:douban][:apikey]}&redirect_uri=http://127.0.0.1:9393/login_callback/douban/&response_type=code&scope=book_basic_r,douban_basic_common"
end

get '/login_callback/douban/?' do
  resp = HTTParty.post("https://www.douban.com/service/auth2/token?client_id=#{settings.config[:douban][:apikey]}&client_secret=#{settings.config[:douban][:secret]}&code=#{params[:code]}&grant_type=authorization_code&redirect_uri=http://127.0.0.1:9393/login_callback/douban/",
    :headers => {"Accept"=> "application/json"})
  info = JSON::parse(resp.body, symbolize_names: true)
  u = User.first(dbid: info[:douban_user_id])
  unless u
    user_resp = HTTParty.get("https://api.douban.com/v2/user/~me", :headers => {"User-Agent" => "AsReader", "Authorization" => "Bearer #{info[:access_token]}"})
    user_info  = JSON::parse(user_resp.body, symbolize_names: true)
    user = User.new
    user.name = user_info[:name]
    user.dbid = info[:douban_user_id]
    user.access_token = info[:access_token]
    user.refresh_token = info[:refresh_token]
    user.save
    u = user
  end
  cookies[:login] = u.dbid
  redirect '/home/'
end

get '/home/?' do
  u =  User.first(dbid: cookies[:login])
  return "Welcome, #{u.name}"
end
