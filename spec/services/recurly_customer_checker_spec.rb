require_relative '../../app/services/recurly_account_checker'
require 'recurly'
describe RecurlyAccountChecker do 
  let(:user) { stub }
  let(:customer_id) { -1 }
  let(:customer) { stub }
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

end
