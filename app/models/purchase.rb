class Purchase < ApplicationRecord
  belongs_to :customer_payment_method
  belongs_to :product
  belongs_to :company
  has_one :receipt, dependent: :destroy
  has_one :fraud, dependent: :destroy

  after_create :generate_token_attribute
  after_create :automatic_fraud

  enum status: { fraud_pending: 0, pending: 5, rejected: 7, paid: 10 }

  validates :cost, presence: true

  def validate_product_is_not_subscription
    return unless product.subscription?

    errors.add :product, 'não crie cobrança de assinatura diretamente pela API'
  end

  def self.process_where_params(params)
    where_params = {}
    customer_payment_method = {}

    customer_payment_method[:customer] = Customer.find_by(token: params[:customer_token])
    customer_payment_method[:type_of] = params[:type]
    where_params[:product] = Product.find_by(token: params[:product_token])

    where_params.compact!
    customer_payment_method.compact!
    return where_params if customer_payment_method.empty?

    where_params[:customer_payment_method] = customer_payment_method
    where_params
  end

  def self.search(params, company_object)
    @purchases = Purchase.all.where(company: company_object)
    return @purchases if params.empty?

    valid_key_list = %w[customer_token type product_token]
    invalid_key_list = params.keys - valid_key_list
    return nil unless invalid_key_list.empty?

    where_params = process_where_params params

    @purchases = @purchases.includes(:customer_payment_method).where(where_params)
  end

  def automatic_fraud
    rejected! if last_seven_days? && both_rejected?
  end

  def both_rejected?
    if last_purchase != false && penultimate_purchase != false
      last_purchase.status == 'rejected' && penultimate_purchase.status == 'rejected'
    else
      false
    end
  end

  def last_seven_days?
    if last_purchase != false && penultimate_purchase != false
      (last_purchase.created_at.to_date - penultimate_purchase.created_at.to_date).to_i < 7
    else
      false
    end
  end

  def last_purchase
    customer = customer_payment_method.customer
    purchases = Purchase.all.where(customer_payment_method: customer.customer_payment_methods)

    if purchases.length >= 2
      _last_purchase = purchases[purchases.length - 2]
    else
      false
    end
  end

  def penultimate_purchase
    customer = customer_payment_method.customer
    purchases = Purchase.all.where(customer_payment_method: customer.customer_payment_methods)

    if purchases.length >= 3
      _penultimate_purchase = purchases[purchases.length - 3]
    else
      false
    end
  end
end
