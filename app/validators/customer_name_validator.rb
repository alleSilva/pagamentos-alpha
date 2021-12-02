class CustomerNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.chars.grep(/\d+/).count.zero?

    record.errors.add attribute, (options[:message] || 'não pode conter números')
  end
end
