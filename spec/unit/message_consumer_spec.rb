require 'spec_helper'

module EventPubSub

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
    it { should respond_to(:get_listeners_of) }
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

  describe "#get_listeners_of" do
    context "Given a event called new_sku_added with ExampleListener class associated" do
      let(:listener_definitions) do
        { new_sku_added: ["ExampleListenerClass"] }
      end

      subject{ MessageConsumer.new(config, logger) }

      it "returns [ExampleListenerClass]" do
        result = subject.get_listeners_of('new_sku_added', listener_definitions)
        expect(result).to eql ['ExampleListenerClass']
      end
    end

    context "Given a listener called AllEventsListener mapped for any event" do
      let(:listener_definitions) do
        { any_event: ["AllEventListenerClass"] }
      end

      subject{ MessageConsumer.new(config, logger) }

      it "returns [AllEventListenerClass]" do
        result = subject.get_listeners_of('foo_bar_updated', listener_definitions)
        expect(result).to eql ['AllEventListenerClass']
      end
    end

    context "Given a listener called AllEventsListener mapped for any event and new_sku_added mapped to ExampleListener" do
      let(:listener_definitions) do
        { new_sku_added: ["ExampleListenerClass"], any_event: ["AllEventListenerClass"] }
      end

      subject{ MessageConsumer.new(config, logger) }

      it "for 'new_sku_added' event returns [ExampleListenerClass, AllEventListenerClass]" do
        result = subject.get_listeners_of('new_sku_added', listener_definitions)
        expect(result).to eql ['ExampleListenerClass', 'AllEventListenerClass']
      end

      it "for 'product_selled' event returns [AllEventListenerClass]" do
        result = subject.get_listeners_of('product_selled', listener_definitions)
        expect(result).to eql ['AllEventListenerClass']
      end
    end
  end
end
end

