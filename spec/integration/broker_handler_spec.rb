require 'spec_helper'
module Event
describe BrokerHandler do
  let(:logger){ double('logger', debug: true)}
  let(:running_server_config) do
    {
      ip: "localhost",
      port: "5672",
      username: "guest",
      password: "guest",
    }
  end

  let(:stopped_server_config) do
    {
      ip: "localhost",
      port: "4000",
      username: "guest",
      password: "guest",
    }
  end

  describe "#start_connection" do
    context "given a up and running RabbitMQ server at localhost:5672" do
      subject{ BrokerHandler.new(running_server_config, logger) }
      it "stabilish connection" do
        expect{subject.start_connection}.to_not raise_error
      end
    end

    context "given a stoped RabbitMQ server" do
      subject{ BrokerHandler.new(stopped_server_config, logger) }
      it "raise error" do
        expect{ subject.start_connection }.to raise_error
      end
    end
  end

  describe "#close_connection" do
    context "given a up and running RabbitMQ server at localhost:5672" do
      subject{ BrokerHandler.new(running_server_config, logger) }

      it "closes connection" do
        subject.start_connection
        expect{subject.close_connection}.to_not raise_error
      end

      it "closes the channel" do
        channel = subject.start_connection
        expect(channel).to receive(:close).once
        subject.close_connection
      end
    end
  end

  describe "#publish" do
    context "given a up and running RabbitMQ server at localhost:5672" do
      subject do
        bus = BrokerHandler.new(running_server_config, logger)
        bus.start_connection

        bus
      end
      it "publish the event using base_routing_key" do
        expect{ subject.publish( "'data': 'sample data'", 'routing.key') }.to_not raise_error
      end
    end
  end

end
end

