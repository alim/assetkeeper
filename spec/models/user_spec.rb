require 'spec_helper'

describe User, :type => :model do
	include_context 'user_setup'

  before(:all) {
  	User.destroy_all
  }

	before(:each) {
		create_users
	}

	after(:each) {
		delete_users
  }

  # METHOD CHECKS ------------------------------------------------------
	describe "Should respond to all accessor methods" do
		it { is_expected.to respond_to(:email) }
		it { is_expected.to respond_to(:password) }
		it { is_expected.to respond_to(:password_confirmation) }
		it { is_expected.to respond_to(:remember_me) }
		it { is_expected.to respond_to(:first_name) }
		it { is_expected.to respond_to(:last_name) }
		it { is_expected.to respond_to(:phone) }
		it { is_expected.to respond_to(:authentication_token) }
		it { is_expected.to respond_to(:role) }
		it { is_expected.to respond_to(:role_str) }
		it { is_expected.to respond_to(:sign_in_count) } # added by Fred
		it { is_expected.to respond_to(:owns) }
	end

	# ACCESSOR TESTS -----------------------------------------------------
	describe "First name examples" do
		let(:get_first_name) {
			@user = User.first
			@first_name = @user.first_name
		}

		it "Should strip extra trailing spaces" do
			get_first_name
			@user.first_name = @first_name + '    	    '
			@user.save

			expect(@user.first_name).to eq(@first_name)
		end

		it "Should strip extra leading spaces" do
			get_first_name
			@user.first_name = '    	    ' + @first_name
			@user.save

			expect(@user.first_name).to eq(@first_name)
		end

		it "Should not be valid without a first_name" do
			get_first_name
			@user.first_name = nil
			expect(@user).not_to be_valid
			expect(@user.errors.full_messages[0]).to match(/First name can't be blank/)
		end
	end

	describe "Last name examples" do
		let(:get_last_name) {
			@user = User.last
			@last_name = @user.last_name
		}

		it "Should strip extra trailing spaces" do
			get_last_name
			@user.last_name = @last_name + '    	    '
			@user.save

			expect(@user.last_name).to eq(@last_name)
		end

		it "Should strip extra leading spaces" do
			get_last_name
			@user.last_name = '    	    ' + @last_name
			@user.save

			expect(@user.last_name).to eq(@last_name)
		end

		it "Should not be valid without a last_name" do
			get_last_name
			@user.last_name = nil
			expect(@user).not_to be_valid
			expect(@user.errors.full_messages[0]).to match(/Last name can't be blank/)
		end
	end

	describe "Phone examples" do
		let(:get_phone) {
			@user = User.first
			@phone = @user.phone
		}

		it "Should strip extra trailing spaces" do
			get_phone
			@user.phone = @phone + '    	    '
			@user.save

			expect(@user.phone).to eq(@phone)
		end

		it "Should strip extra leading spaces" do
			get_phone
			@user.phone = '    	    ' + @phone
			@user.save

			expect(@user.phone).to eq(@phone)
		end

		it "Should not be valid without a phone" do
			get_phone
			@user.phone = nil
			expect(@user).not_to be_valid
			expect(@user.errors.full_messages[0]).to match(/Phone can't be blank/)
		end
	end

	describe "Email examples" do
		let(:get_email) {
			@user = User.first
			@email = @user.email
		}

		it "Should strip extra trailing spaces" do
			get_email
			@user.email = @email + '    	    '
			@user.save

			expect(@user.email).to eq(@email)
		end

		it "Should strip extra leading spaces" do
			get_email
			@user.email = '    	    ' + @email
			@user.save

			expect(@user.email).to eq(@email)
		end

		it "Should not be valid without a email" do
			get_email
			@user.email = nil
			expect(@user).not_to be_valid
			expect(@user.errors.full_messages[0]).to match(/Email can't be blank/)
		end

		it "Should not allow creation of User with existing email" do
			get_email
			user = FactoryGirl.create(:user)
			user.email = @user.email

			expect(user).not_to be_valid
			expect(user.errors.full_messages.count).to eq(2)
		end
	end

	describe "Role examples" do
		let(:get_role) {
			@user = User.last
			@role = @user.role
		}

		it "Should not be valid without a role" do
			get_role
			@user.role = nil
			expect(@user).not_to be_valid
			expect(@user.errors.full_messages.count).to eq(1)
		end

		it "Should not allow invalid role" do
			get_role
			@user.role = 99

			expect(@user).not_to be_valid
			expect(@user.errors.full_messages[0]).to match(/Role is invalid/)
		end
	end

	# INSTANCE METHOD CHECKS ---------------------------------------------
	describe "Role string method" do
		it "Should return a matching string for Customer" do
			user = User.first
			expect(user.role_str).to match(/Customer/)
		end

		it "Should return a matching string for Service Admin" do
			user = User.last
			user.role = User::SERVICE_ADMIN
			expect(user.role_str).to match(/Service Administrator/)
		end

		it "Should return unknown if no matching role" do
			user = User.last
			user.role = 99
			expect(user.role_str).to match(/Unknown/)
		end
	end

	# DEFINED SCOPE TESTS ------------------------------------------------
	describe "Scope tests" do

		describe "Search by email" do
			it "Should find all records for broad email search" do
				expect(User.by_email("person").count).to eq(User.count)
			end

			it "Should find a single record for full email address" do
				user = User.last
				expect(User.by_email(user.email).first.email).to eq(user.email)
			end

			it "Should not find any records, if email does not match" do
				expect(User.by_email("Mickey Mouse").count).to eq(0)
			end

			it "Should find all records, if email is empty" do
				expect(User.by_email('').count).to eq(User.count)
			end
		end

		describe "Search by first name" do
			it "Should find all records for broad first name search" do
				expect(User.by_first_name("John").count).to eq(User.count)
			end

			it "Should find a single record for full first name" do
				user = User.last
				expect(User.by_first_name(user.first_name).first.first_name).to eq(user.first_name)
			end

			it "Should not find any records, if first name does not match" do
				expect(User.by_first_name("Mickey Mouse").count).to eq(0)
			end

			it "Should find all records, if first_name is empty" do
				expect(User.by_first_name('').count).to eq(User.count)
			end
		end

		describe "Search by last name" do
			it "Should find all records for broad last name search" do
				expect(User.by_last_name("Smith").count).to eq(User.count)
			end

			it "Should find a single record for full last name" do
				user = User.first
				expect(User.by_last_name(user.last_name).first.last_name).to eq(user.last_name)
			end

			it "Should not find any records, if last name does not match" do
				expect(User.by_first_name("Mickey Mouse").count).to eq(0)
			end

			it "Should find all records, if last_name is empty" do
				expect(User.by_last_name('').count).to eq(User.count)
			end
		end

		describe "Search by role" do
		  it "Should find all customer records" do
		    create_service_admins
		    customers = User.where(role: User::CUSTOMER)
		    user = User.by_role(User::CUSTOMER)
		    expect(user.count).to eq(customers.count)
		  end

		  it "Should find no service admin records, if none exist" do
		    user = User.by_role(User::SERVICE_ADMIN)
		    expect(user.count).to eq(0)
		  end

		  it "Should find no records, if no role specified" do
		    user = User.by_role(nil)
		    expect(user.count).to eq(0)
		  end

		  it "Should find all service admin users" do
		    create_service_admins
		    admins = User.where(role: User::SERVICE_ADMIN)

		    user = User.by_role(User::SERVICE_ADMIN)
		    expect(user.count).to eq(admins.count)
		  end

		  it "Should be able to chain a customer search onto all users" do
		    users = User.all
		    customers = User.where(role: User::CUSTOMER)
		    users = users.by_role(User::CUSTOMER)
		    expect(users.count).to eq(customers.count)
		  end

		  it "Should be able to chain a service admin search onto all users" do
		    users = User.all
		    admins = User.where(role: User::SERVICE_ADMIN)
		    users = users.by_role(User::SERVICE_ADMIN)
		    expect(users.count).to eq(admins.count)
		  end

		  it "Should be able to chain a nil search onto all users" do
		    users = User.all
		    admins = User.where(role: User::SERVICE_ADMIN)
		    users = users.by_role(nil)
		    expect(users.count).to eq(0)
		  end
		end
	end # Defined scope tests

	# Class Criteria Tests for search/filter -----------------------------
	# TODO: Add search filter tests for User Model


	# Nested / embedded Account Tests ------------------------------------

	describe "Nested/embedded Account Tests" do
	  before(:each) {
	    create_users_with_account
	    @user = User.where(:account.exists => true).last
	  }

	  describe "Valid tests" do
	    it "Should be valid to have an embedded account" do
	      expect(@user).to be_valid
	    end

	    it "Should have an account customer_id" do
	      expect(@user.account.customer_id).to be_present
	    end

	    it "Should have an account status ACTIVE" do
	      expect(@user.account.status).to eq(Account::ACTIVE)
	    end
	  end
	end
end
