module Event
  class MessageProducer
    def initialize(config, logger)
      raise ArgumentError, "missing module base_routing_key " unless config[:base_routing_key]
      @base_routing_key = config[:base_routing_key]
      @logger = logger

      @broker_handler = BrokerHandler.new(config[:broker], @logger)
      @logger.info '[MessageProducer] - Starting Connection'
      @broker_handler.start_connection
    end

    def publish(event_name, msg={})
      key = routing_key(event_name)
      msg[:event_name] = event_name
      if defined?(Rails)
        msg[:event_date] = Time.zone.now
      else
        msg[:event_date] = DateTime.now
      end
      @logger.info '[MessageProducer] - Sending event: #{event_name}'
      @logger.debug "[MessageProducer] - Sending event: #{event_name} with data: #{msg.inspect} using as routing_key: #{key}"
      @broker_handler.publish( JSON.generate(msg), key )
    end

    private
    def routing_key(event_name)
      "#{@base_routing_key}.#{event_name}"
    end
  end
end
