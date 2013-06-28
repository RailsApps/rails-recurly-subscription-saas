require_relative '../../app/services/recurly_account_checker'
require 'recurly'
describe RecurlyAccountChecker, '.customer_exists?' do 
  subject { described_class.customer_exists?(customer_id) }
  let(:customer_id) { -1 }

  context "when customer exist" do 
    before { Recurly::Account.stub(:find).with(customer_id) { true } }

    it { should be_true }
  end

end
