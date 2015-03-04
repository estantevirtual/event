require 'spec_helper'

module Event

describe MessageConsumer do
  let(:logger) { double(:log, debug: true, info: true) }
  let(:config) do
    { broker: {
        ip: "localhost",
        port: "5672",
        username: "guest",
        password: "guest"
      },
      base_routing_key: "module_name"
    }
  end

  describe "API" do
    subject{ MessageConsumer.new(config, logger) }
    it { should respond_to(:execute) }
    it { should respond_to(:fire_listeners_of) }
  end

  describe ".initialize" do
    it "raise ArgumentError when no config was given" do
      expect{ MessageConsumer.new }.to raise_error(ArgumentError)
    end

    it "raise ArgumentError if invalid config was given" do
      expect{ MessageConsumer.new({}) }.to raise_error(ArgumentError)
    end

    it "no raise error if a valid config was given" do
      expect{ MessageConsumer.new(config, logger) }.to_not raise_error
    end
  end

  describe "#fire_listeners_of" do
    context "Given a event called new_sku_added with ExampleListener class associated" do
      let(:listener_instance){ double(:ExampleListenerInstance, notify: true) }
      let(:example_listener_class){ double(:ExampleListenerClass, :new => listener_instance) }
      let(:listener_definitions) do
        { new_sku_added: [example_listener_class] }
      end
      let(:message){"event_name : 'new_sku_added', price : 10.0"}

      subject{ MessageConsumer.new(config, logger) }

      it "calls example_listener_class#new" do
        expect(example_listener_class).to receive(:new).once
        subject.fire_listeners_of('new_sku_added', listener_definitions, message )
      end

      it "calss example_listener_class#notify" do
        expect(listener_instance).to receive(:notify).once
        subject.fire_listeners_of('new_sku_added', listener_definitions, message )
      end
    end
  end
end
end

