def cpf_sequence(sequence_number)
  number_string = format('%011d', sequence_number)
  "#{number_string.slice(0, 2)}"\
    "#{number_string.slice(1, 3)}"\
    "#{number_string.slice(4, 3)}"\
    "#{number_string.slice(8, 4)}"\
    "#{number_string.slice(12, 2)}"
end

FactoryBot.define do
  factory :customer do
    name { 'Customer da Silva' }
    sequence(:cpf) do |n|
      cpf_sequence n
    end
    company { nil }
  end
end
