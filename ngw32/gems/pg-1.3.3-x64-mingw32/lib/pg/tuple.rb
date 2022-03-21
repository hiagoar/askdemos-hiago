# -*- ruby -*-
# frozen_string_literal: true

require 'pg' unless defined?(PG)

module PG
  class Tuple
    ### Return a String representation of the object suitable for debugging.
    def inspect
      "#<#{self.class} #{map { |k, v| "#{k}: #{v.inspect}" }.join(', ')}>"
    end

    def has_key?(key)
      field_map.key?(key)
    end
    alias key? has_key?

    def keys
      field_names || field_map.keys.freeze
    end

    def each_key(&block)
      if fn = field_names
        fn.each(&block)
      else
        field_map.each_key(&block)
      end
    end
  end
end
