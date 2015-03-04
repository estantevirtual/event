require 'spec_helper'

describe Event do
  subject{ Event }
  describe "api" do
    it { expect(subject).to respond_to :bootstrap }
    it { expect(subject).to respond_to :publish }
    it { expect(subject).to respond_to :add_listeners }
  end

  describe ".publish" do
    it "calls MessageBus#publish" do
      bus = spy("bus")
      allow(Event::MessageProducer).to receive(:new).and_return(bus)
      Event.publish(:event_name, {data: :value})
      expect(bus).to have_received(:publish)
    end
  end

  describe ".register_listeners" do
    it "configure the listeners in a declarative way" do
      Event.register_listeners do |config|
        config.add_listeners(:sku_added_listener, ['SkuAddedListener'])
        config.add_listeners(:sku_image_changed, ['SkuImageChangedListener', 'AnotherListener'])
      end
      expect(Event.listeners).to include(sku_added_listener: ['SkuAddedListener'])
      expect(Event.listeners).to include(sku_image_changed: ['SkuImageChangedListener', 'AnotherListener'])
    end
  end

  describe ".add_listeners" do
    context "Given a event named: sku_added and a EventListener called sku_added_listener" do
      let(:sku_added_listener){ double(:sample_event_listener) }
      let(:event_name){ :sku_added }
      it "register a new EventListener for a event" do
        Event.add_listeners(event_name, [ sku_added_listener ])
        expect(Event.listeners).to include( sku_added: [ sku_added_listener ])
      end
    end
  end

end
