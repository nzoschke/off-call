require "json"
require "rest-client"

module OffCall

  def self.apply_environment!(filename=".env")
    read_environment(filename).each { |k,v| ENV[k] = v }
  end

  def self.read_environment(filename)
    return {} unless File.exists?(filename)

    File.read(filename).split("\n").inject({}) do |hash, line|
      if line =~ /\A([A-Za-z_0-9]+)=(.*)\z/
        key, val = [$1, $2]
        case val
          when /\A'(.*)'\z/ then hash[key] = $1
          when /\A"(.*)"\z/ then hash[key] = $1.gsub(/\\(.)/, '\1')
          else hash[key] = val
        end
      end
      hash
    end
  end

  module PagerDuty
    class Schedule
      def initialize(subdomain, user, password, id)
        @id  = id
        @api = RestClient::Resource.new("https://#{subdomain}.pagerduty.com/api/beta/schedules/#{@id}", user: user, password: password)
      end

      def add_override(user_id, start_dt, end_dt)
        # TODO: check if exact override already exists
        params = {
          override: {
            user_id:  user_id,
            start:    start_dt.strftime("%Y-%m-%dT%H:%M:%S"),
            end:      end_dt.strftime("%Y-%m-%dT%H:%M:%S"),
          }
        }

        @api["overrides"].post(params.to_json, content_type: "application/json")
      end
    end
  end

end