require 'time'
require 'bunny'
require 'logger'
require "event_pub_sub/version"
require 'event_pub_sub/broker_handler'
require 'event_pub_sub/message_producer'
require 'event_pub_sub/message_consumer'
require 'event_pub_sub/listener'
require 'json'
require 'securerandom'

module Event
  warn "[DEPRECATION] This gem has been renamed to event-pub-sub and will no longer be supported. Please switch to event-pub-sub as soon as possible."
end