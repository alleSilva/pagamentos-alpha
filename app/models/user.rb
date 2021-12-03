class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  belongs_to :company, optional: true

  validates :email, private_email: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  before_validation :check_ownership_and_company_unless_already_set
  after_validation :create_company!, if: :user_is_owner_without_company?

  def incomplete_company?
    company&.incomplete?
  end

  def accepted_company?
    company&.accepted?
  end

  def owns?(received_company)
    received_company.owner == self
  end

  def in_company?(received_company)
    received_company == company
  end

  private

  def retrieve_registered_company
    email_domain_query_element = "%@#{email.split('@')[-1]}"

    same_email_domain_users = User.where(
      'email LIKE :email_domain',
      email_domain: email_domain_query_element
    ).where.not(company: nil)

    return nil if same_email_domain_users.empty?

    same_email_domain_users.first.company
  end

  def check_ownership_and_company_unless_already_set
    return if owner || company

    registered_company = retrieve_registered_company
    self.owner = registered_company.nil?

    return if owner

    if registered_company&.accepted?
      self.company = registered_company
    else
      errors.add :base, 'Sua empresa ainda não foi aceita no nosso sistema'
    end
  end

  def user_is_owner_without_company?
    !company && owner
  end
end
