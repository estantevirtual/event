require 'time'
require 'bunny'
require 'logger'
require "event/version"
require 'event/broker_handler'
require 'event/message_producer'
require 'event/message_consumer'
require 'event/listener'
require 'json'

module Event
  extend self
  require 'event/railtie' if defined?(Rails)

  @listeners ||= {}

  def bootstrap(config)
    @configuration = config
    @logger = Logger.new('log/event_producer.log')
    @logger.level = Logger::INFO
  end

  def listen_events!
    Thread.new do
      logger = Logger.new('log/event_consumer.log')
      logger.level = Logger::INFO
      consumer = MessageConsumer.new(@configuration, logger)
      consumer.execute(listeners)
    end
  end

  def publish(event_name, data={})
    @producer ||= MessageProducer.new(@configuration, @logger)
    @producer.publish(event_name.to_sym, data)
  end

  def listeners
   @listeners.clone
  end

  def register_listeners(&block)
    instance_eval(&block)
  end

  def add_listeners(event_name, new_listeners=[])
    if new_listeners.any?
      key = event_name.to_sym
      @listeners[key] ||= []
      @listeners[key].concat(new_listeners)
    end
  end

end