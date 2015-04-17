require 'event'
require 'rails'
module EventPubSub
  class Railtie < Rails::Railtie
    railtie_name :event_bus

    rake_tasks do
      load "tasks/event_tasks.rake"
    end
  end
end