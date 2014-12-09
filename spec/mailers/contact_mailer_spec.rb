require "spec_helper"

describe ContactMailer, :type => :mailer do
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    
    # Collect al deliveries into an array
    ActionMailer::Base.deliveries = []
    
    @contact = FactoryGirl.build(:contact)
    @contact_email = ContactMailer.contact_message(@contact).deliver
  end
  
  
  after(:each) do
    ActionMailer::Base.deliveries.clear
  end
  
  it 'should send an email' do
    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end
  
  it 'renders the receiver email' do
    expect(ActionMailer::Base.deliveries.first.to).to eq([@contact.email])
  end
  
  it 'renders the sender email' do  
    expect(ActionMailer::Base.deliveries.first.from).to eq([ContactMailer::CONTACT_FROM])
  end
    
end
