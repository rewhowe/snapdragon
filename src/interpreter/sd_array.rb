require_relative '../string'
require_relative 'formatter'

module Interpreter
  class SdArray < Hash
    class << self
      def from_array(values)
        new.tap { |sa| 0.upto(values.size - 1).zip(values).each { |k, v| sa.set k, v } }
      end

      def from_hash(kv_pairs)
        new.tap { |sa| kv_pairs.each { |k, v| sa.set k, v } }
      end
    end

    ## Setters and Getters

    def set(index, value)
      self[format_index index] = value
    end

    def get(index)
      self[format_index index]
    end

    def get_at(index)
      return nil if index.negative?
      self[keys[index]]
    end

    def first
      get_at 0
    end

    def last
      get_at keys.length - 1
    end

    def range(range)
      SdArray.from_hash (keys[range] || []).map { |key| [key, self[key]] }
    end

    ## Mutators

    ##
    # Ignoring named keys, adds the element with the next successive numeric
    # key, retaining insertion order.
    # Does not change existing keys.
    def push!(element)
      set next_numeric_index, element
    end

    ##
    # Removes the last element in insertion order.
    # Does not change existing keys.
    def pop!
      last_key = keys.last
      last_element = self[last_key]
      delete last_key
      last_element
    end

    ##
    # Adds the element at the 0th index.
    # Rekeys numeric keys.
    def unshift!(element)
      old_entries = clone
      clear
      set 0, element
      concat! old_entries, 1
      self
    end

    ##
    # Removes the first element in insertion order.
    # Rekeys numeric keys.
    def shift!
      first_key = keys.first
      first_element = self[first_key]
      delete first_key

      old_entries = clone
      clear
      concat! old_entries, 0

      first_element
    end

    # def sort!
    #   numeric_keys, named_keys = partition { |k, v| k.numeric? }
    #   clear
    #   numeric_keys.sort_by { |(k, _v)| k.to_f } .each { |(k, v)| self[k.to_s] = v }
    #   named_keys.sort.each { |(k, v)| self[k] = v }
    #   self
    # end

    ##
    # Appends source to self.
    # Rekeys numeric keys from source with starting_index.
    # Overlapping named keys overwrite source.
    def concat!(source, starting_index = nil)
      next_index = starting_index || next_numeric_index

      source.each do |k, v|
        if k.numeric?
          set next_index, v
          next_index += 1
        else
          set k, v
        end
      end

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

    def next_numeric_index
      last_index = nil
      keys.each do |k|
        last_index = k if k.numeric? && (last_index.nil? || k > last_index)
      end
      last_index.nil? ? 0 : last_index.to_i + 1
    end
  end
end
