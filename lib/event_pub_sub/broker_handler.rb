module EventPubSub
  class BrokerHandler

    def initialize(config, logger)
      raise ArgumentError, "missing broker ip" unless config[:ip]
      raise ArgumentError, "missing broker port" unless config[:port]
      raise ArgumentError, "missing broker username" unless config[:username]
      raise ArgumentError, "missing broker password" unless config[:password]
      @config = config
      @logger = logger
    end

    def start_connection
      @connection = build_connection
      @connection.start
      rescue => e
        @logger.error "#{e.message} - #{e.class}\n #{e.backtrace.join("\n")}"
    end

    def close_connection
      @connection.close
    end

    def publish(message, routing_key)
      topic.publish( message, persistent: true, routing_key: routing_key )
    end

    def setup_queue(queue_name)
      @queue = channel.queue(queue_name, durable: true, auto_delete: false)
      @queue.bind(topic, routing_key: '#')
    end

    def subscribe(consumer_name, params={ack: true, block: false}, &block)
      params[:consumer_tag] = consumer_name
      @queue.subscribe(params) do |delivery_info, properties, payload|
        begin
          block.call(delivery_info, properties, payload)
          channel.ack(delivery_info.delivery_tag)
        rescue => e
          channel.nack(delivery_info.delivery_tag, false, false)
          raise e
        end
      end
    end

    private
    def build_connection
      Bunny.new(
        host: @config[:ip],
        port: @config[:port],
        user: @config[:username],
        pass: @config[:password]
      )
    end

    def topic
      @topic ||= channel.topic('topic_events', durable: true)
    end


    def channel
      @channel ||= @connection.create_channel(nil, workers_total)
    end

    def workers_total
      ENV['TOTAL_RABBIT_WORKERS'].nil? ? 4 : ENV['TOTAL_RABBIT_WORKERS'].to_i
    end
  end
end
