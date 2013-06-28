class RecurlyAccountChecker

  def self.customer_exists?(customer_id)
    retrieve_customer(customer_id)
  end

  private
  def self.retrieve_customer(customer_id, &block)
    customer = Recurly::Account.find(customer_id) unless customer_id.nil?
    yield if block_given?
    true
  rescue Recurly::Resource::NotFound => e
    logger.error e.message
    errors.add :base, "Unable to create your subscription. #{e.message}"
    false
  end

end
