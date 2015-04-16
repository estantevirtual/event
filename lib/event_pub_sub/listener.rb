module EventPubSub
  class Listener
    def notify
      fail NotImplementedError, "You must implement notify method in #{self.class}"
    end
  end
end