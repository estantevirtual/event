require 'spec_helper'
module Event
describe MessageProducer do
  let(:logger) { double(:log, debug: true, info: true) }
  let(:config) do
    {
      broker: {
        ip: "localhost",
        port: "5672",
        username: "guest",
        password: "guest"
      },
      base_routing_key: "module_name"
    }
  end

  describe "API" do
    subject{ MessageProducer.new(config, logger)}
    it { should respond_to :publish }
  end

  describe "initialize" do
    it "raise Argument Error when no config is given" do
      expect{MessageProducer.new}.to raise_error ArgumentError
    end

    it "raise ArgumentError error with a invalid config" do
      expect{MessageProducer.new('aaaaa')}.to raise_error ArgumentError
    end

    it "raise ArgumentError error with a incomplete config" do
      expect{MessageProducer.new({})}.to raise_error ArgumentError
      expect{MessageProducer.new({ip: 1})}.to raise_error ArgumentError
      expect{MessageProducer.new({ip: 1, port: 2})}.to raise_error ArgumentError
      expect{MessageProducer.new({ip: 1, port: 2, username: 'a'})}.to raise_error ArgumentError
      expect{MessageProducer.new({ip: 1, port: 2, username: 'a', password: "123"})}.to raise_error ArgumentError
    end

    it "not raise error with a valid config" do
      expect{MessageProducer.new(config, logger)}.to_not raise_error
    end
  end

  describe "#publish" do
    context "Given a event named 'sku_created' with data => {code: 10, price: 20.87, product_id: 2}" do
      let(:event_name){ :sku_created }
      let(:event_data) do
        { code: 10, price: 20.87, product_id: 2, event_name: 'sku_created' }
      end
      let(:expected_message){ JSON.generate(event_data) }
      let(:fake_broker){double('broker', start_connection: true )}

      subject{ MessageProducer.new(config, logger)}

      it "calls BrokerHandler#publish with message => {code: 10, price: 20.87, product_id: 2} and routing_key => module_name.sku_created" do
        allow(BrokerHandler).to receive(:new).and_return fake_broker
        expect(fake_broker).to receive(:publish).once
        subject.publish(event_name, event_data)
      end
    end
  end

end
end

