# require 'event'
# require 'yaml'

# module YourModuleNameHere
#   class Event
#     broker_data = File.read( File.expand_path('../../event.yml',__FILE__) )
#     broker_config = YAML.load(ERB.new(broker_data).result).with_indifferent_access
#     @@message_producer = ::Event::MessageProducer.new(broker_config[Rails.env], Rails.logger)

#     if !Rails.env.test?
#       listener_data = File.read( File.expand_path('../../listeners.yml',__FILE__) )
#       listeners = YAML.load(listener_data).with_indifferent_access

#       if listeners.any?
#         Thread.new do
#           consumer = ::Event::MessageConsumer.new(broker_config[Rails.env], Rails.logger)
#           consumer.execute(listeners)
#         end
#       end
#     end

#     def self.publish(event_name, data={})
#       @@message_producer.publish(event_name.to_sym, data)
#     end
#   end
# end