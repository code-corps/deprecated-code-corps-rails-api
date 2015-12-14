RSpec::Matchers.define :be_a_valid_json_api_error do
  def hash_has_nonempty_error_key?
    return false unless @hash.has_key? :errors
    return false unless @hash[:errors].class == Array
    return false unless @hash[:errors].length > 0
    return true
  end

  def all_errors_in_hash_are_valid?
    return false unless @hash[:errors].all? { |error| is_valid? error }
    return true
  end

  def is_valid?(error)
    error = error.with_indifferent_access
    return false unless error.has_key? :id
    return false unless error.has_key? :title
    return false unless error.has_key? :detail
    return false unless error.has_key? :status
    return true
  end

  def id_is_correct
    @hash[:errors].first[:id] == @expected_id
  end

  match do |hash|
    @hash = hash.with_indifferent_access
    result = hash_has_nonempty_error_key? and all_errors_in_hash_are_valid?
    result &&= id_is_correct unless @expected_id.nil?
    result
  end

  chain :with_id do |expected_id|
    @expected_id = expected_id
  end
end

RSpec::Matchers.define :be_a_valid_json_api_validation_error do
  def hash_has_nonempty_error_key?
    return false unless @hash.has_key? :errors
    return false unless @hash[:errors].class == Array
    return false unless @hash[:errors].length > 0
    return true
  end

  def all_errors_in_hash_are_validation_errors?
    return false unless @hash[:errors].all? { |error| is_validation_error? error }
    return true
  end

  def is_validation_error?(error)
    error = error.with_indifferent_access
    return false unless error[:id] == "VALIDATION_ERROR"
    return false unless error.has_key? :source
    return false unless error[:source].has_key? :pointer
    return false unless error.has_key? :detail
    return false unless error[:status] == 422
    return true
  end

  def hash_contains_error_with_message? message
    errors = @hash[:errors]
    errors.any? { |error| error[:detail] == message }
  end

  def hash_contains_errors_with_messages? messages
    errors = @hash[:errors]
    messages.each do |message|
      error = errors.detect { |error| error[:detail] == message }
      return false unless error.present?
      errors.delete(error)
    end
    return true
  end

  match do |hash|
    @hash = hash.with_indifferent_access
    result = hash_has_nonempty_error_key? and all_errors_in_hash_are_validation_errors?
    result &&= hash_contains_error_with_message? @message unless @message.nil?
    result &&= hash_contains_errors_with_messages? @messages unless @messages.nil?
    result
  end

  chain :with_message do |message|
    @message = message
  end

  chain :with_messages do |messages|
    @messages = messages
  end
end


RSpec::Matchers.define :contain_an_error_of_type do  |expected_type|
  def there_is_an_error_with_id expected
    return @errors.any? { |e| e[:id] == expected }
  end

  def there_is_an_error_with_message expected
    return @errors.any? { |e| e[:detail] == expected }
  end

  match do |hash|
    @errors = hash.with_indifferent_access[:errors].map(&:with_indifferent_access)
    result = there_is_an_error_with_id expected_type
    result &&= there_is_an_error_with_message @expected_message unless @expected_message.nil?
  end

  chain :with_message do |expected_message|
    @expected_message = expected_message
  end
end
