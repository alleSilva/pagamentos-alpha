FactoryBot.define do
  factory :customer_subscription do
    company { create(:company, status: :accepted) }
    status { 'active' }
    cost { 9.99 }
    renovation_date { 1 }
    product { create(:product, type_of: 'subscription', company: company) }
    customer_payment_method { create(:customer_payment_method, :pix, company: company) }
  end
end
