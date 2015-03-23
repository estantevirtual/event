require 'yaml'

unless Rails.env.test?
  config = YAML.load(ERB.new(File.read(File.expand_path("../../event.yml",__FILE__))).result).with_indifferent_access
  # Starts the Event Magic ;)
  Event.bootstrap(config[Rails.env])
  #
  # Register your listeners Here!!!! Example:
  # Event.register_listeners do |config|
  #   config.add_listeners(:event_name, ['EventNameListener'])
  #   config.add_listeners(:another_event_name, ['AnotherEventListener1', 'Listener2'])
  # end
  #
  # Starts the Event Listener ;)
  Event.listen_events!
end
