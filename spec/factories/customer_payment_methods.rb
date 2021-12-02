FactoryBot.define do
  factory :customer_payment_method do
    company { create(:company, status: :accepted) }
    customer { create(:customer, company: company) }
    type_of { 'pix' }

    trait :pix do
      pix_setting { create(:pix_setting) }
      type_of { 'pix' }
    end

    trait :boleto do
      boleto_setting { create(:boleto_setting) }
      type_of { 'boleto' }
    end

    trait :credit_card do
      type_of { 'credit_card' }
      credit_card_setting { create(:credit_card_setting) }
      credit_card_name { 'Credit Card 1' }
      credit_card_number { '4929513324664053' }
      credit_card_expiration_date { 3.months.from_now }
      credit_card_security_code { '123' }
    end
  end
end
