require 'flipper/rules/condition'
require 'flipper/rules/any'
require 'flipper/rules/all'

module Flipper
  module Rules
    def self.wrap(thing)
      if thing.is_a?(Flipper::Rules::Rule)
        thing
      else
        build(thing)
      end
    end

    def self.build(hash = {})
      if block_given?
        yield Flipper::Rules::Builder.new
      else
        type = const_get(hash.fetch("type"))
        type.build(hash.fetch("value"))
      end
    end
  end
end
