$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'bundler'
Bundler.setup(:default, :test)
require 'event_pub_sub'
require 'pry'
require 'byebug'
