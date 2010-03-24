class Alexandria
  module Net
    class HTTP < ::Net::HTTP
      def initialize(*)
        super
        self.verify_mode = OpenSSL::SSL::VERIFY_NONE if port == 443
      end
    end
  end
end

Resourceful::NetHttpAdapter::Net = Alexandria::Net