require "chronic"
require "json"
require "rest-client"
require "time"

ENV.instance_eval do
  def source(filename)
    return {} unless File.exists?(filename)

    env = File.read(filename).split("\n").inject({}) do |hash, line|
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

    env.each { |k,v| ENV[k] = v unless ENV[k] }
  end
end

class String
  def to_time
    Time.parse(self) rescue Chronic.parse(self)
  end

  def trunc(len)
    if (self.length > len)
      self[0...len-3] + "..."
    else
      self
    end
  end
end

class Hash
  def reverse_merge!(h)
    replace(h.merge(self))
  end
end

module OffCall
  module PagerDuty

    def self.api
      @api || raise("Initialize with PagerDuty.connect")
    end

    def self.connect(subdomain, user, password)
      @api = RestClient::Resource.new("https://#{subdomain}.pagerduty.com/api/", user: user, password: password)
    end

    class Service
      def initialize(id)
        @id = id
      end

      def incidents(opts={})
        opts.reverse_merge!(until: Time.now, since: Time.now-60*60*24)
        params = {
          service:  @id,
          until:    opts[:until].iso8601,
          since:    opts[:since].iso8601
        }

        JSON.parse(PagerDuty.api["v1/incidents"].get(params: params))["incidents"]
      end
    end

    class Schedule
      def initialize(subdomain, user, password, id)
        @id  = id
        @api = PagerDuty.api["beta/schedules/#{@id}"]
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