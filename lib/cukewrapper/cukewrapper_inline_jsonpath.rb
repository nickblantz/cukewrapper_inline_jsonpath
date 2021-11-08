# frozen_string_literal: true

module Cukewrapper
  # I process data >:^)
  class InlineJSONPathRemapper < Remapper
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
        handle_datatables(datatables)
      end
    end

    def handle_datatables(datatables)
      Cukewrapper.log.debug("#{self.class.name}\##{__method__}") { 'Adding datatables' }
      datatables.each do |datatable|
        @inline_remaps += datatable[1..].map { |arr| { path: arr[0], value: arr[1] } }
      end
    end

    private

    def remap!(data)
      @inline_remaps.each do |remap|
        Cukewrapper.log.debug("#{self.class.name}\##{__method__}") do
          "Remapping '#{remap[:path]}' to '#{remap[:value]}'"
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
      Cukewrapper.log.debug("#{self.class.name}\##{__method__}") { "Merging value '#{raw}'" }
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
      Cukewrapper.log.debug("#{self.class.name}\##{__method__}") { "Evaluating '#{raw}'" }
      # rubocop:disable Security/Eval
      eval raw
      # rubocop:enable Security/Eval
    end

    def parse(raw)
      Cukewrapper.log.debug("#{self.class.name}\##{__method__}") { "Parsing '#{raw}'" }
      return nil if raw == ''

      JSON.parse(raw)
    end
  end
end
