$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'bundler'
Bundler.setup(:default, :test)
require 'event'
require 'pry'
require 'pry-byebug'
