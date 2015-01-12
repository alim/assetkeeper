require 'spec_helper'

RSpec.describe "manufacturers/show", :type => :view do
  before(:each) do
    @manufacturer = assign(:manufacturer, Manufacturer.create!(
      :name => "Name",
      :address => "Address",
      :website => "Website",
      :main_phone => "Main Phone",
      :main_fax => "Main Fax",
      :tags => "Tags"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Address/)
    expect(rendered).to match(/Website/)
    expect(rendered).to match(/Main Phone/)
    expect(rendered).to match(/Main Fax/)
    expect(rendered).to match(/Tags/)
  end
end
