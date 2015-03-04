require 'spec_helper'

module Event
  describe Listener do
    describe "api" do
      it { is_expected.to respond_to :notify }
    end

    describe "#notify" do
      it "raises NotImplementedError in order to remember the developer to override this operation on subclasses" do
        expect{suject.notify}.to raise_error
      end
    end
  end
end

