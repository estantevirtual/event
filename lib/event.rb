require 'time'
require 'bunny'
require 'logger'
require "event/version"
require 'event/broker_handler'
require 'event/message_producer'
require 'event/message_consumer'
require 'event/listener'
require 'json'
require 'fileutils'

module Event
  extend self
  require 'event/railtie' if defined?(Rails)

  @listeners ||= {}

  def bootstrap(config)
    @configuration = config
    log_filename = "log/#{config[:base_routing_key]}_event_producer.log"
    ensure_file_exists(log_filename)
    @logger = Logger.new(log_filename)
    @logger.level = Logger::INFO
  end

  def listen_events!
    Thread.new do
      log_filename = "log/#{@configuration[:base_routing_key]}_event_consumer.log"
      ensure_file_exists(log_filename)
      logger = Logger.new(log_filename)
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

  private

  def ensure_file_exists(file_path)
    dirname = File.dirname(file_path)
    unless File.directory?(dirname)
      FileUtils.mkdir_p(dirname)
    end
  end

end