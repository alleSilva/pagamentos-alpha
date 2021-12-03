class CustomerSubscription < ApplicationRecord
  belongs_to :product
  belongs_to :customer_payment_method
  belongs_to :company

  # TODO: mudar de pendente/cancelada para ativa quando a cobrança for paga
  enum status: { active: 0, pending: 5, canceled: 10 }

  validates :cost, presence: true, numericality: true
  validates :renovation_date, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 28 }

  before_validation :create_renovation_date
  after_create :generate_token_attribute

  def self.renew_subscriptions
    today = Time.zone.today

    today_subscriptions = CustomerSubscription.where(
      '(renovation_date = :day AND created_at < :last_month AND status = :active) OR '\
      '(retry_date = :today AND status = :pending AND tried_renew_times < 3)',
      day: today.day, last_month: (today - 28.days), active: statuses[:active],
      today: today, pending: statuses[:pending]
    )

    create_today_purchases(today_subscriptions, today)
  end

  # TODO: chamar esse metodo no Purchase quando for aprovada
  def self.retry_purchase_creation(customer_payment_method:, product:)
    customer_subscription = CustomerSubscription.find_by(
      customer_payment_method: customer_payment_method,
      product: product
    )

    return handle_retry_renovation(customer_subscription) if customer_subscription.tried_renew_times < 2

    handle_cancel_subscription(customer_subscription)
  end

  def validate_product_is_not_single
    return unless product&.single?

    errors.add :product, 'sua assinatura precisa ser vinculada com um product do tipo subscription'
  end

  private

  def create_renovation_date
    today = Time.zone.today.day
    self.renovation_date = today > 28 ? 1 : today
  end

  class << self
    def create_today_purchases(today_subscriptions, today)
      today_subscriptions.each do |s|
        Purchase.create(company: s.company, customer_payment_method: s.customer_payment_method,
                        product: s.product, cost: s.cost, expiration_date: today)
      end
    end

    # TODO: resetar esses atributos quando alterar de pendente/cancelada para ativa
    def handle_retry_renovation(customer_subscription)
      customer_subscription.retry_date = Time.zone.today + 2.days
      customer_subscription.tried_renew_times += 1
      customer_subscription.status = 'pending'

      customer_subscription.save!
    end

    def handle_cancel_subscription(customer_subscription)
      customer_subscription.tried_renew_times += 1
      customer_subscription.status = 'canceled'

      customer_subscription.save!
    end
  end
end
