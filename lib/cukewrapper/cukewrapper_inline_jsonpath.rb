# frozen_string_literal: true

module Cukewrapper
  # I process data >:^)
  class InlineJSONPathRemapper < Remapper
    require 'faker'
    require 'jsonpath'

    priority :low

    def initialize
      super
      @inline_remaps = []
    end

    def run(context)
      remap!(context['data'])
    end

    def register_hooks
      Hooks.register("#{self.class.name}:after_datatables", :after_datatables) do |_context, datatables|
        add_remaps(datatables)
      end
    end

    def add_remaps(datatables)
      datatables.each do |datatable|
        remap = datatable[1..].map { |arr| { path: arr[0], value: arr[1] } }
        LOGGER.debug("#{self.class.name}\##{__method__}") { remap }
        @inline_remaps += datatable[1..].map { |arr| { path: arr[0], value: arr[1] } }
      end
    end

    private

    def remap!(data)
      @inline_remaps.each do |remap|
        LOGGER.debug("#{self.class.name}\##{__method__}") do
          "#{remap[:path].inspect} => #{remap[:value].inspect}"
        end
        JsonPath
          .for(data)
          .gsub!(remap[:path], &value_remapper(remap[:value]))
      end
    end

    def value_remapper(raw)
      lambda do |current_value|
        prefix = raw[0]
        if prefix == '~'
          merge(current_value, raw[1..])
        else
          evaluate_or_parse(raw)
        end
      end
    end

    def merge(value, raw)
      LOGGER.debug("#{self.class.name}\##{__method__}") { raw }
      parsed = evaluate_or_parse(raw)
      merge_result(value, parsed)
    end

    def merge_result(value, parsed)
      case parsed
      when Array
        value + parsed
      when Hash
        parsed.each { |k, v| value[k] = v }
        value
      when NilClass
        value
      else
        parsed
      end
    end

    def evaluate_or_parse(raw)
      prefix = raw[0]
      if prefix == '#'
        evaluate(raw[1..])
      else
        parse(raw)
      end
    end

    def evaluate(raw)
      LOGGER.debug("#{self.class.name}\##{__method__}") { raw }
      # rubocop:disable Security/Eval
      eval raw
      # rubocop:enable Security/Eval
    end

    def parse(raw)
      return nil if raw == ''

      LOGGER.debug("#{self.class.name}\##{__method__}") { raw }
      JSON.parse(raw)
    end
  end
end
