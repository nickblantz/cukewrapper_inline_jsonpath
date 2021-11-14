# frozen_string_literal: true

module Cukewrapper
  # I process data >:^)
  class InlineJSONPathRemapper < Remapper
    require 'date'
    require 'faker'
    require 'jsonpath'

    DATATABLE_HEADER = %w[JSONPath Value].freeze

    priority :low

    def run(context)
      return unless @enabled

      context['data'] ||= {}
      remap!(context['data'])
    end

    def register_hooks
      Hooks.register("#{self.class.name}:enable", :after_datatables, &enable)
    end

    def enable
      lambda do |_context, datatables|
        @remaps = datatables.flat_map(&to_remaps)
        @enabled = !@remaps.empty?
        LOGGER.debug("#{self.class.name}\##{__method__}") { @enabled }
      end
    end

    private

    def to_remaps
      lambda do |table|
        return [] unless table[0] == DATATABLE_HEADER

        table[1..].map { |arr| { path: arr[0], value: arr[1] } }
      end
    end

    def remap!(data)
      @remaps.each do |remap|
        JsonPath.for(data).delete!(remap[:path]) if remap[:value] == ''

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
