module Event
  class MessageConsumer
    def initialize(config, logger)
      raise ArgumentError, "missing module base_routing_key " unless config[:base_routing_key]
      @queue_name = config[:base_routing_key]
      @logger = logger
      @broker_handler = BrokerHandler.new(config[:broker], @logger)
      @logger.info '[MessageConsumer] - Starting Connection'
      @broker_handler.start_connection
      @broker_handler.setup_queue(@queue_name)
    end

    def execute(all_listeners)
      @logger.info '[MessageConsumer] - Waiting Messages...'
      consumer_name = "#{@queue_name}_event_consumer"
      @broker_handler.subscribe(consumer_name) do |delivery_info, properties, payload|
        message = JSON.parse(payload).with_indifferent_access
        event_name = message['event_name']
        @logger.info "[MessageConsumer] - Message Received: #{event_name}"
        fire_listeners_of(event_name, all_listeners, message)
      end
    end

    def close_connection
      @logger.info '[MessageConsumer] - Closing Connection'
      @broker_handler.close_conection
    end

    def fire_listeners_of(event_name, listeners_definitions, data)
      listeners = listeners_definitions[event_name.to_sym]
      if listeners
        listeners.each do |listener_klass_name|
          @logger.info "[Event Handling] - notify event '#{event_name}' using class '#{listener_klass_name}' with args '#{data}'"
          begin
            listener_klass = Object.const_get(listener_klass_name)
            listener_klass.new(data).notify
          rescue => e
            @logger.error "[Event Handling] - #{e}"
          end
        end
      end
    end

  end
end
