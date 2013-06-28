class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :remember_me, :card_token, :customer_id
  attr_accessor :card_token
  before_create :check_recurly
  before_destroy :cancel_subscription

  def name
    name = "#{first_name.capitalize} #{last_name.capitalize}"
  end

  def check_recurly
    recurly_account_checker.customer_exists?
  end

  def update_plan(role)
    recurly_account_checker.update_subscriber(role)
  end

  def update_recurly
    recurly_account_checker.update_customer
  end

  def cancel_subscription
    customer = Recurly::Account.find(customer_id) unless customer_id.nil?
    subscription = customer.subscriptions.first unless customer.nil?
    if (!subscription.nil?) && (subscription.state == 'active')
      subscription.cancel
    end
  rescue Recurly::Resource::NotFound => e
    logger.error e.message
    errors.add :base, "Unable to cancel your subscription. #{e.message}"
    false
  end

  def expire
    UserMailer.expire_email(self).deliver
    destroy
  end

  private
  def recurly_account_checker
    RecurlyAccountChecker.new(self)
  end

end
