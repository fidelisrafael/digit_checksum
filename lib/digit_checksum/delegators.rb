module DigitChecksum
  class BaseDocument

    CLASS_METHODS_DELEGATES = [
      :valid?,
      :invalid?,
      :pretty,
      :strip,
      :normalize,
      :as_array,
      :formatted,
      :clear,
      :remove_verify_digits!,
      :append_verify_digits!,
      :calculate_verify_digits,
      :valid_length?
    ]

    CLASS_METHODS_DELEGATES.each do |method_name|
      define_singleton_method method_name do |number|
        new(number).public_send(method_name)
      end
    end
  end
end
