class RecurlyAccountChecker
  attr_reader :user 

  def initialize(user)
    @user = user
  end

  def customer_exists?
    !customer.nil?
  end

  def cancel_subscription
    handle_recurly_exception do 
      if customer_exists?
        subscription.cancel if !subscription.nil? && subscription.state == 'active'
      end
    end
  end

  def update_customer 
    handle_recurly_exception do 
      if customer_exists?
        customer.email = user.email
        customer.first_name = user.first_name
        customer.last_name = user.last_name
        customer.save!
      end
    end
  end

  def update_subscriber(role)
    handle_recurly_exception do
      user.role_ids = []
      user.add_role role.name
      subscription.update_attributes! :timeframe => 'now', :plan_code => role.name if customer_exists?
    end
  end


  def customer
    @customer ||= retrieve_customer
  end

  private
  def customer_id
    user.customer_id 
  end

  def subscription
    @subscription ||= customer.subscriptions.first
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
