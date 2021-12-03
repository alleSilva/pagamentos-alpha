FactoryBot.define do
  factory :purchase do
    company { create(:company, status: :accepted) }
    customer_payment_method { create(:customer_payment_method, :pix, company: company) }
    product { create(:product, company: company) }
    cost { '9.99' }
    receipt { nil }
    paid_date { '2021-11-29' }
    expiration_date { '2021-11-29' }
  end
end
