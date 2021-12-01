class Purchase < ApplicationRecord
  belongs_to :customer_payment_method
  belongs_to :pix_setting, optional: true
  belongs_to :boleto_setting, optional: true
  belongs_to :credit_card_setting, optional: true
  belongs_to :product
  belongs_to :receipt, optional: true
  belongs_to :company

  enum type_of: { pix: 0, boleto: 5, credit_card: 10 }

  after_create :generate_token_attribute

  def self.search(params, company_object)
    @purchases = Purchase.all.where(company: company_object)
    return @purchases if params.empty?

    if params.count <= 3
      if params.key?(:customer_token)
        customer = Customer.find_by(token: params[:customer_token])
        customer_payment_method = CustomerPaymentMethod.find_by(customer: customer)
        @purchases = @purchases.where(customer_payment_method: customer_payment_method)
        params.delete(:customer_token)
      end

      if params.key?(:type)
        @purchases = @purchases.where(type_of: params[:type])
        params.delete(:type)
      end

      if params.key?(:product_token)
        product_filter = Product.find_by(token: params[:product_token])
        @purchases = @purchases.where(product: product_filter)
        params.delete(:product_token)
      end

      if params.empty?
        @purchases
      else
        @purchases = nil
      end
    end
  end
end
