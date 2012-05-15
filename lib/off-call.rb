class OffCall

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

end