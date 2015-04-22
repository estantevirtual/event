module EventPubSub
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
        @event_name = message['event_name']
        @logger.info "[MessageConsumer] - Message Received: #{event_name}"
        listeners_to_execute = get_listeners_of(event_name, all_listeners)
        fire_listeners(listeners_to_execute, message)
      end
    end

    def close_connection
      @logger.info '[MessageConsumer] - Closing Connection'
      @broker_handler.close_conection
    end

    def get_listeners_of(event_name, listeners_definitions)
      listeners = listeners_definitions[event_name.to_sym] || []
      if has_any_event_mapping?(listeners_definitions)
        listeners.concat get_any_event_listeners(listeners_definitions)
      end

      listeners
    end

    private
    def fire_listeners(listeners_to_execute, data)
      if listeners_to_execute
        listeners_to_execute.each do |listener_klass_name|
          @logger.info "[Event Handling] - using listener class '#{listener_klass_name}'"
          @logger.debug "[Event Handling] - notify event '#{@event_name}' using listener class '#{listener_klass_name}' with args '#{data}'"
          begin
            listener_klass = Object.const_get(listener_klass_name)
            listener_klass.new(data).notify
          rescue => e
            @logger.error "[Event Handling] - #{e} \n #{e.backtrace.join("\n")}"
            raise e
          end
        end
      end
    end

    def has_any_event_mapping?(listeners_definitions)
      listeners_definitions[:any_event] && listeners_definitions[:any_event].any?
    end

    def get_any_event_listeners(listeners_definitions)
      listeners_definitions[:any_event]
    end

  end
end
