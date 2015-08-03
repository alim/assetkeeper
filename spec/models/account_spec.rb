require 'spec_helper'

describe Account, :type => :model do
  include_context 'user_setup'

  before(:each) {
    create_users_with_account
  }

  after(:each) {
  	Organization.destroy_all
    User.destroy_all
  }

  # METHOD CHECKS ------------------------------------------------------
	describe "Method check" do
		it { is_expected.to respond_to(:status) }
		it { is_expected.to respond_to(:customer_id)}
		it { is_expected.to respond_to(:status_str) }
		it { is_expected.to respond_to(:stripe_cc_token) }
		it { is_expected.to respond_to(:cardholder_email) }
		it { is_expected.to respond_to(:cardholder_name)}
		it { is_expected.to respond_to(:last4) }
		it { is_expected.to respond_to(:card_type) }
		it { is_expected.to respond_to(:expiration) }
	end

	# STATUS STRING CHECKS -----------------------------------------------
	describe "Status string checks" do
	  before(:each){
	    @account = User.ne(account: nil).first.account
	  }

	  it "Should return Unknown string for UNKNOWN status" do
	    @account.status = Account::UNKNOWN
	    expect(@account.status_str).to eq("Unknown")
	  end

	  it "Should return Active string for ACTIVE status" do
	    @account.status = Account::ACTIVE
	    expect(@account.status_str).to eq("Active")
	  end

	  it "Should return InActive string for INACTIVE status" do
	    @account.status = Account::INACTIVE
	    expect(@account.status_str).to eq("Inactive")
	  end

	  it "Should return Closed string for CLOSED status" do
	    @account.status = Account::CLOSED
	    expect(@account.status_str).to eq("Closed")
	  end

	  it "Should return No Stripe Account string for NO_STRIPE status" do
	    @account.status = Account::NO_STRIPE
	    expect(@account.status_str).to eq("No Stripe Account")
	  end
	end

	# STRIPE.COM INTERACTIONS --------------------------------------------
	describe "Stripe Interactions" do
    let(:cardnum) { "4242424242424242" }
    let(:email) { "andylim@example.com" }
    let(:name) { "Andy Lim" }
    let(:cvcvalue) { "313" }

    let(:user) { User.first }

    describe "Saving with stripe attributes" do

    	# context "Valid attributes", :vcr do
    	context "Valid attributes" do

		    let(:token) do
		    	@token = get_token(name, cardnum, Date.today.month, (Date.today.year + 1),
		    		cvcvalue)
		  	end

		    let(:params) do
		    	{
						cardholder_name: name,
						cardholder_email: email,
						account: {stripe_cc_token: @token.id}
		    	}
		    end

		    before { token }

	      it "Should allow saving with stripe information to account record" do
				  expect(user.account.save_with_stripe(params)).to be_truthy
			  end

			  it "Should update account with stripe customer id" do
			    expect(user.account.save_with_stripe(params)).to be_truthy
			    expect(user.account.customer_id).to be_present
			  end

			  it "Should update account with stripe customer email" do
			    expect(user.account.save_with_stripe(params)).to be_truthy
			    expect(user.account.cardholder_email).to eq(params[:cardholder_email])
			  end

			  it "Should update account with stripe customer name" do
			    expect(user.account.save_with_stripe(params)).to be_truthy
			    expect(user.account.cardholder_name).to eq(params[:cardholder_name])
			  end

			  it "Should update account with last4 of credit card" do
			    expect(user.account.save_with_stripe(params)).to be_truthy
			    expect(user.account.last4).to eq(cardnum.split(//).last(4).join)
			  end

			  it "Should set account with credit card_type" do
			    expect(user.account.save_with_stripe(params)).to be_truthy
			    expect(user.account.card_type).to eq("Visa")
			  end

			  it "Should set account with credit card expiration date" do
			    expect(user.account.save_with_stripe(params)).to be_truthy
			    expect(user.account.expiration).to eq(@token.card[:exp_month].to_s + '/' +
			      @token.card[:exp_year].to_s)
			  end

			  it "Should update account status to ACTIVE" do
			    expect(user.account.save_with_stripe(params)).to be_truthy
			    expect(user.account.status).to eq(Account::ACTIVE)
			  end
			end

			# context 'Invalid stripe attributes', :vcr do
			context 'Invalid stripe attributes' do

		    let(:token) do
	    		@token = get_token(name, cardnum, Date.today.month, (Date.today.year + 1),
	    			cvcvalue)
		    end

		    let(:params) do
		    	{
						cardholder_name: name,
						cardholder_email: email,
						account: {stripe_cc_token: @token.id}
		    	}
		    end

		    before { token }

			  it "Should not save the account with an invalid token" do
			    params[:account][:stripe_cc_token] = '123451234512345'
			    expect(user.account.save_with_stripe(params)).to be_falsey

			    expect(user.account.status).to eq(Account::INACTIVE)
				  #expect(user.account.errors.full_messages[0]).to match(/Customer There is no token with ID 123451234512345/)
				  expect(user.account.errors.full_messages[0]).to match(/Customer No such token: 123451234512345/)
				end
			end
		end

		describe "Updating with stripe attributes" do
	    let(:new_email) { "janedoe@example.com" }
	    let(:new_name) { "Jane Doe" }

			# context "Valid stripe account update tests", :vcr do
			context "Valid stripe account update tests" do

		    let(:first_token) do
		    	@first_token = get_token(name, cardnum, Date.today.month, (Date.today.year + 1),
		    		cvcvalue)
				end

		    let(:second_token) do
		    	@second_token = get_token(new_name, cardnum, Date.today.month, (Date.today.year + 2),
		    		cvcvalue)
				end

		  	let(:params) do
			  	{
					  cardholder_name: name,
					  cardholder_email: email,
					  account: {stripe_cc_token: @first_token.id}
					}
			  end

			  let(:update_params) do
			  	{
					  cardholder_name: new_name,
					  cardholder_email: new_email,
					  account: {stripe_cc_token: @second_token.id}
					}
			  end

			  before do
			  	first_token
			  	second_token
			  end

			  it "Should update a saved account with new attributes" do
			    expect(user.account.save_with_stripe(params)).to be_truthy
			    customer_id = user.account.customer_id

			    # Update record and check attributes
			    expect(user.account.update_with_stripe(update_params)).to be_truthy
			    expect(user.account.customer_id).to eq(customer_id)
			  end


			  it "Should update account with stripe customer email" do
			    expect(user.account.save_with_stripe(params)).to be_truthy
			    expect(user.account.update_with_stripe(update_params)).to be_truthy
			    expect(user.account.cardholder_email).to eq(update_params[:cardholder_email])
			  end

			  it "Should update account with stripe customer name" do
			    expect(user.account.save_with_stripe(params)).to be_truthy
			    expect(user.account.update_with_stripe(update_params)).to be_truthy
			    expect(user.account.cardholder_name).to eq(update_params[:cardholder_name])
			  end

			  it "Should update account with last4 of credit card" do
			    expect(user.account.save_with_stripe(params)).to be_truthy
			    expect(user.account.update_with_stripe(update_params)).to be_truthy
			    expect(user.account.last4).to eq(cardnum.split(//).last(4).join)
			  end

			  it "Should set account with credit card_type" do
			    expect(user.account.save_with_stripe(params)).to be_truthy
			    expect(user.account.update_with_stripe(update_params)).to be_truthy
			    expect(user.account.card_type).to eq("Visa")
			  end

			  it "Should set account with credit card expiration date" do
			    expect(user.account.save_with_stripe(params)).to be_truthy
			    expect(user.account.update_with_stripe(update_params)).to be_truthy
			    expect(user.account.expiration).to eq(@second_token.card[:exp_month].to_s + '/' +
			      @second_token.card[:exp_year].to_s)
			  end

			  it "Should update a saved account and status should be ACTIVE" do
			    expect(user.account.save_with_stripe(params)).to be_truthy

			    # Update record and check attributes
			    expect(user.account.update_with_stripe(update_params)).to be_truthy
			    expect(user.account.status).to eq(Account::ACTIVE)
			  end
			end

			# context "Updating with invalid stripe attributes", :vcr do
			context "Updating with invalid stripe attributes" do

		    let(:third_token) do
		    	@third_token = get_token(name, cardnum, Date.today.month, (Date.today.year + 1),
		    		cvcvalue)
				end

		    let(:forth_token) do
		    	@forth_token = get_token(new_name, cardnum, Date.today.month, (Date.today.year + 2),
		    		cvcvalue)
				end

		  	let(:params) do
			  	{
					  cardholder_name: name,
					  cardholder_email: email,
					  account: {stripe_cc_token: third_token.id}
					}
			  end

			  let(:update_params) do
			  	{
					  cardholder_name: new_name,
					  cardholder_email: new_email,
					  account: {stripe_cc_token: forth_token.id}
					}
			  end

			  it "Should not update the account with an invalid token" do
			    expect(user.account.save_with_stripe(params)).to be_truthy
			    update_params[:account][:stripe_cc_token] = '123412341234'

			    # Update record and check attributes
			    expect(user.account.update_with_stripe(update_params)).to be_falsey
			    expect(user.account.status).to eq(Account::INACTIVE)
			  end
			end

		end

		describe "Get customer method" do

			# context "Valid customer get operation tests", :vcr do
			context "Valid customer get operation tests" do

				let(:name) { 'Mickey Mouse' }

				let(:info_token) do
		    	@info_token = get_token(name, cardnum, Date.today.month, (Date.today.year + 3),
		    		cvcvalue)
				end

		  	let(:params) do
			  	{
					  cardholder_name: name,
					  cardholder_email: email,
					  account: {stripe_cc_token: @info_token.id}
					}
			  end

			  before { info_token }

			  it "Should retrieve the correct email address" do
				  expect(user.account.save_with_stripe(params)).to be_truthy
				  user.account.get_customer
				  expect(user.account.cardholder_email).to eq(email)
			  end

			  it "Should retrieve the correct cardholder name" do
				  expect(user.account.save_with_stripe(params)).to be_truthy
				  user.account.get_customer
				  expect(user.account.cardholder_name).to eq(name)
			  end

			  it "Should retrieve the correct cardholder last 4 digits" do
				  expect(user.account.save_with_stripe(params)).to be_truthy
				  user.account.get_customer
				  expect(user.account.last4).to eq(cardnum.split(//).last(4).join)
			  end

			  it "Should retrieve the correct card expiration" do
				  expect(user.account.save_with_stripe(params)).to be_truthy
				  user.account.get_customer

				  month = @info_token.card[:exp_month].to_s
				  year = @info_token.card[:exp_year].to_s
				  expect(user.account.expiration).to match(/#{month}\/#{year}/)
			  end

	      it "Should have a status of ACTIVE" do
				  expect(user.account.save_with_stripe(params)).to be_truthy
				  user.account.get_customer
				  expect(user.account.status).to eq(Account::ACTIVE)
			  end
			end

			# context 'Invalid get customer data tests', :vcr do
			context 'Invalid get customer data tests' do

				let(:name) { 'Mickey Mouse' }

				let(:info_token) do
	    		get_token(name, cardnum, Date.today.month, (Date.today.year + 3),
	    			cvcvalue)
				end

		  	let(:params) do
			  	{
					  cardholder_name: name,
					  cardholder_email: email,
					  account: {stripe_cc_token: info_token.id}
					}
			  end

			  it "Should return an error, if customer_id is invalid" do
			    expect(user.account.save_with_stripe(params)).to be_truthy
			    user.account.customer_id = '1234123412341234'
			    expect(user.account.get_customer).to be_nil
					expect(user.account.errors.full_messages[0]).to match(/Customer No such customer:/)
			  end
			end
		end
	end # Stripe interactions
end
