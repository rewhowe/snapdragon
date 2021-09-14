require_relative '../string'
require_relative 'formatter'

module Interpreter
  class SdArray < Hash
    attr_accessor :next_numeric_index
    class << self
      def from_array(values)
        new.tap do |sa|
          0.upto(values.size - 1).zip(values).each { |k, v| sa[k.to_f.to_s] = v }
          sa.next_numeric_index = values.length
        end
      end

      def from_hash(kv_pairs)
        new.tap { |sa| kv_pairs.each { |k, v| sa.set k, v } }
      end

      def from_sd_array(sd_array)
        new.tap do |sa|
          sd_array.each do |key, value|
            case value
            when SdArray then sa[key] = SdArray.from_sd_array(value)
            when String  then sa[key] = value.dup
            else              sa[key] = value
            end
          end
          sa.next_numeric_index = sd_array.next_numeric_index
        end
      end
    end

    def initialize
      @next_numeric_index = 0
    end

    ## Setters and Getters

    def set(index, value)
      formatted_index = format_index index
      @next_numeric_index = index.to_i + 1 if formatted_index.numeric? && index.to_i >= @next_numeric_index
      self[formatted_index] = value
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

    def first=(value)
      return if keys.length.zero?
      set keys.first, value
    end

    def last
      get_at keys.length - 1
    end

    def last=(value)
      return if keys.length.zero?
      set keys.last, value
    end

    def formatted_keys
      SdArray.from_array(keys.map { |key| key.numeric? ? key.to_f : key })
    end

    def range(range)
      SdArray.new.tap { |sa| (keys[range] || []).map { |k| sa.contextual_set! k, self[k] } }
    end

    ## Mutators

    ##
    # Ignoring named keys, adds the element with the next successive numeric
    # key, retaining insertion order.
    # Does not change existing keys.
    def push!(element)
      set @next_numeric_index, element
    end

    ##
    # Contextually pushes numeric-keyed values or sets non-numeric-keyed values.
    # Essentially for resetting numeric keys.
    # Does not change existing keys.
    def contextual_set!(key, value)
      if key.numeric?
        push! value
      else
        set key, value
      end
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
      @next_numeric_index = 0
      push! element
      concat! old_entries
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
      @next_numeric_index = 0
      concat! old_entries

      first_element
    end

    ##
    # Appends source to self.
    # Rekeys numeric keys from source.
    # Overlapping named keys overwrite target.
    def concat!(source)
      source.each { |k, v| contextual_set! k, v }
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

    def slice!(range)
      SdArray.new.tap do |sa|
        (keys[range] || []).map do |key|
          sa.contextual_set! key, self[key]
          delete key
        end
      end
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
