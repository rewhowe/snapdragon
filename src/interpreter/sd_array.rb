require_relative '../string'
require_relative 'formatter'

module Interpreter
  class SdArray < Hash
    def set(index, value)
      self[format_index index] = value
    end

    def get(index)
      self[format_index index]
    end

    ##
    # Ignoring named keys, adds the element with the next successive numeric key.
    def push!(element)
      last_index = nil
      keys.each do |k|
        last_index = k if k.numeric? && (last_index.nil? || k > last_index)
      end
      next_index = last_index.nil? ? 0 : last_index.to_i + 1

      set next_index, element
    end

    ##
    # Does not ignore named keys.
    def pop!
      last_key = keys.last
      last_element = self[last_key]
      delete last_key
      last_element
    end

    ##
    # Reorders keys.
    def unshift!(element)
      old_entries = clone
      clear
      set 0, element
      concat! old_entries
    end

    ##
    # Does not ignore named keys or reorder keys.
    def shift!
      first_key = keys.first
      first_element = self[first_key]
      delete first_key
      first_element
    end

    # def sort!
    #   numeric_keys, named_keys = partition { |k, v| k.numeric? }
    #   clear
    #   numeric_keys.sort_by { |(k, _v)| k.to_f } .each { |(k, v)| self[k.to_s] = v }
    #   named_keys.sort.each { |(k, v)| self[k] = v }
    #   self
    # end

    # Resets and concatenates numeric keys, merges named keys.
    def concat!(source)
      self_numeric_keys, self_named_keys = partition { |k, _v| k.numeric? }

      clear

      self_numeric_keys.each_with_index { |(_k, v), i| set i, v }
      last_index = size

      source_numeric_keys, source_named_keys = source.partition { |k, _v| k.numeric? }
      source_numeric_keys.each_with_index { |(_k, v), i| set last_index + i, v }

      merge! self_named_keys.to_h.merge(source_named_keys.to_h)
      self
    end

    def remove!(element)
      each do |k, v|
        next unless v == element

        delete k
        return true
      end
      false
    end

    def remove_all!(element)
      removed = SdArray.new
      each do |k, v|
        next unless v == element

        removed.push! element
        delete k
      end
      removed
    end

    private

    def format_index(index)
      if (index.is_a?(String) && index.numeric?) || index.is_a?(Numeric)
        index.to_f.to_s
      else
        Formatter.interpolated index
      end
    end
  end
end
