require_relative '../../app/services/recurly_account_checker'
require 'recurly'
describe RecurlyAccountChecker do 
  let(:user) { stub }
  let(:customer) { stub }
  let(:customer_id) { -1 }
  before do 
    user.stub(:customer_id) { customer_id } 
    Recurly::Account.stub(:find) { customer } 
  end

  context "#customer_exists?" do 
    subject { described_class.new(user).customer_exists? }

    it { should be_true }
  end

  context "#update_subscriber" do 
    let(:role) { stub }
    let(:subscription) { stub }
    subject { described_class.new(user).update_subscriber(role) }
    before do 
      user.stub(:role_ids=) 
      user.stub(:add_role) 
      role.stub(:name) { 'role' }
      subscription.stub(:update_attributes!) { true }
      customer.stub_chain(:subscriptions, :first) { subscription }
    end

    it { should be_true }
  end

  context "#update_customer" do 
    subject { described_class.new(user).update_customer }
    before do 
      user.stub(:email) { 'email@example.com' }
      user.stub(:first_name) { 'first_name' }
      user.stub(:last_name) {  'last_name' }
      customer.stub(:email=).with(user.email)
      customer.stub(:first_name=).with(user.first_name)
      customer.stub(:last_name=).with(user.last_name)
      customer.stub(:save!) { true }
    end

    it { should be_true }
  end

  context "#cancel_subscription" do 
    subject { described_class.new(user).cancel_subscription }
    let(:subscription) { stub }
    before do 
      customer.stub_chain(:subscription, :first) { subscription }
      subscription.stub(:state) { 'active' }
      subscription.stub(:cancel) { true }
    end

    it { should be_true }
  end

end
