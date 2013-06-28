class RecurlyAccountChecker
  attr_reader :user 

  def initialize(user)
    @user = user
  end

  def customer_exists?
    !customer.nil?
  end

  def update_subscriber(role)
    handle_recurly_exception do
      user.role_ids = []
      user.add_role role.name
      if customer_exists?
        subscription = customer.subscriptions.first
        subscription.update_attributes! :timeframe => 'now', :plan_code => role.name
      end
      true
    end
  end

  def customer
    @customer ||= retrieve_customer
  end

  private
  def customer_id
    user.customer_id 
  end

  def user_customer_id_exists?
    !user.customer_id.nil?
  end
  
  def retrieve_customer
    handle_recurly_exception do 
      Recurly::Account.find(customer_id) if user_customer_id_exists?
    end
  end

  def handle_recurly_exception(&block)
    yield 
  rescue Recurly::Resource::NotFound => e
    user.logger.error e.message
    user.errors.add :base, "Unable to create your subscription. #{e.message}"
    false
  end

end
