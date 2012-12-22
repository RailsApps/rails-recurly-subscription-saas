class RecurlyController < ApplicationController
  protect_from_forgery :except => :push

  def push
    notification = Hash.from_xml(request.body())
    render :text => "Request accepted."
    if notification.has_key?('expired_subscription_notification')
      account_code = notification['expired_subscription_notification']['account']['account_code']
      logger.info "Recurly push notification: expired_subscription_notification for account #{account_code}"
      customer = Recurly::Account.find(account_code)
      subscription = customer.subscriptions.first unless customer.nil?
      if (!subscription.nil?) && (subscription.state == 'expired')
        user = User.find_by_customer_id(account_code)
        user.expire unless user.nil?
      end
    end
  rescue Recurly::Resource::NotFound => e
    logger.error "Recurly: #{e.message}"
  rescue ActiveRecord::RecordNotFound => e
    logger.error "Customer record not found: #{e.message}"
  end

  def test
    xml = <<XML
<expired_subscription_notification>
  <account>
    <account_code>1</account_code>
    <username nil="true"></username>
    <email>verena@example.com</email>
    <first_name>Verena</first_name>
    <last_name>Example</last_name>
    <company_name nil="true"></company_name>
  </account>
  <subscription>
    <plan>
      <plan_code>1dpt</plan_code>
      <name>Subscription One</name>
    </plan>
    <uuid>d1b6d359a01ded71caed78eaa0fedf8e</uuid>
    <state>expired</state>
    <quantity type="integer">1</quantity>
    <total_amount_in_cents type="integer">200</total_amount_in_cents>
    <activated_at type="datetime">2010-09-23T22:05:03Z</activated_at>
    <canceled_at type="datetime">2010-09-23T22:05:43Z</canceled_at>
    <expires_at type="datetime">2010-09-24T22:05:03Z</expires_at>
    <current_period_started_at type="datetime">2010-09-23T22:05:03Z</current_period_started_at>
    <current_period_ends_at type="datetime">2010-09-24T22:05:03Z</current_period_ends_at>
    <trial_started_at nil="true" type="datetime">
    </trial_started_at><trial_ends_at nil="true" type="datetime"></trial_ends_at>
  </subscription>
</expired_subscription_notification>
XML
    test_request = HTTPI::Request.new(recurly_push_url)
    test_request.open_timeout = 1 # seconds
    test_request.read_timeout = 1
    test_request.headers = { "Content-Type" => "text/xml" }
    test_request.body = xml
    test_response = HTTPI.post(test_request)
    render :text => "Check server log for result of request to #{recurly_push_url}"
  rescue HTTPClient::ReceiveTimeoutError
    logger.info "Testing push notification listener: sent XML to #{recurly_push_url}"
    render :text => "Check server log for result of request to #{recurly_push_url}"
  end
end
