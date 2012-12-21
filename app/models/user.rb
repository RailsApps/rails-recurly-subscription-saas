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

  def name
    name = "#{first_name.capitalize} #{last_name.capitalize}"
  end

  def check_recurly
    customer = Recurly::Account.find(customer_id) unless customer_id.nil?
  rescue Recurly::Resource::NotFound => e
    logger.error e.message
    errors.add :base, "Unable to create your subscription. #{e.message}"
    false
  end

end
