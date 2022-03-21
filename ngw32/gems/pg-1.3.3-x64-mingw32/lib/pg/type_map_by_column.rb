# -*- ruby -*-
# frozen_string_literal: true

require 'pg' unless defined?(PG)

module PG
  class TypeMapByColumn
    # Returns the type oids of the assigned coders.
    def oids
      coders.map { |c| c&.oid }
    end

    def inspect
      type_strings = coders.map { |c| c ? c.inspect_short : 'nil' }
      "#<#{self.class} #{type_strings.join(' ')}>"
    end
  end
end
