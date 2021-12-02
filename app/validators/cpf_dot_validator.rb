class CpfDotValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.chars.grep('.').count.zero? && value.chars.grep('-').count.zero?

    record.errors.add attribute, (options[:message] || 'deve ser composto apenas por números')
  end
end
