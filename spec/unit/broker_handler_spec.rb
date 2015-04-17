require 'spec_helper'

module EventPubSub
describe BrokerHandler do
  let(:logger) { double(:log, debug: true) }
  let(:config) do
    {
      ip: "localhost",
      port: "5672",
      username: "guest",
      password: "guest"
    }
  end

  describe "API" do
    subject{ BrokerHandler.new(config, logger)}
    it { should respond_to :start_connection }
    it { should respond_to :publish }
    it { should respond_to :close_connection }
  end

  describe "initialize" do
    it "raise Argument Error when no config is given" do
      expect{BrokerHandler.new}.to raise_error ArgumentError
    end

    it "raise ArgumentError error with a invalid config" do
      expect{BrokerHandler.new('aaaaa')}.to raise_error ArgumentError
    end

    it "raise ArgumentError error with a incomplete config" do
      expect{BrokerHandler.new({})}.to raise_error ArgumentError
      expect{BrokerHandler.new({ip: 1})}.to raise_error ArgumentError
      expect{BrokerHandler.new({ip: 1, port: 2})}.to raise_error ArgumentError
      expect{BrokerHandler.new({ip: 1, port: 2, username: 'a'})}.to raise_error ArgumentError
    end

    it "not raise error with a valid config" do
      expect{BrokerHandler.new(config, logger)}.to_not raise_error
    end
  end

  describe "#start_connection" do
    context "Given a RabbitMQ Broker and a BrokerHandler with valid configuration" do
      let(:mocked_rabbitmq_lib){double}
      let(:connection){ double }
      subject{ BrokerHandler.new(config, logger) }

      it "returns a RabbitMQ Connection" do
        expect(subject).to receive(:build_connection).once.and_return(mocked_rabbitmq_lib)
        expect(mocked_rabbitmq_lib).to receive(:start).once.and_return(connection)
        expect(subject.start_connection).to be connection
      end
    end
  end

  describe "#close_connection" do
    context "Given BrokerHandler with a open connection" do
      let(:mocked_rabbitmq_lib){double}
      let(:connection){ double }

      before do
        allow(subject).to receive(:build_connection).and_return(mocked_rabbitmq_lib)
        allow(mocked_rabbitmq_lib).to receive(:start).once.and_return(connection)
      end

      subject{ BrokerHandler.new(config, logger) }

      it "closes a RabbitMQ Connection" do
        subject.start_connection
        expect(mocked_rabbitmq_lib).to receive(:close).once
        subject.close_connection
      end
    end
  end

    describe "#publish" do
    context "given a up and running RabbitMQ server at localhost:5672" do
      let(:mocked_rabbitmq_lib){double(:bunny_mock)}
      let(:channel){double(:channel, topic: true)}
      let(:connection){double(:connection_mock)}
      let(:topic){double(:topic_mock)}
      before do
        allow(subject).to receive(:build_connection).and_return(mocked_rabbitmq_lib)
        allow(mocked_rabbitmq_lib).to receive(:start).once.and_return(connection)
        allow(mocked_rabbitmq_lib).to receive(:create_channel).and_return(channel)
        allow(channel).to receive(:topic).and_return(topic)
      end
      subject{ BrokerHandler.new(config, logger) }

      it "publish the event using base_routing_key" do
        subject.start_connection
        expect(topic).to receive(:publish).once
        subject.publish('message', 'routing.key')
      end
    end
  end


end
end

