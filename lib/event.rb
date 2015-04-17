require 'time'
require 'bunny'
require 'logger'
require "event/version"
require 'event/broker_handler'
require 'event/message_producer'
require 'event/message_consumer'
require 'event/listener'
require 'json'
require 'securerandom'

module Event
  warn "[DEPRECATION] This gem has been renamed to event-pub-sub and will no longer be supported. Please switch to event-pub-sub as soon as possible."
end