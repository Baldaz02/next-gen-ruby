# frozen_string_literal: true

require 'time'
require 'tzinfo'

module NextGen
  module Config
    module Application
      def self.timestamp_to_date(timestamp)
        utc_time = Time.at(timestamp).utc
        tz = TZInfo::Timezone.get('Europe/Rome')

        tz.utc_to_local(utc_time)
      end
    end
  end
end
