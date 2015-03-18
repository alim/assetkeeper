require 'spec_helper'

describe ManufacturerDecorator do
  include_context 'manufacturer_setup'

  before(:each) {
    @decorated_manufacturer = ManufacturerDecorator.new(Manufacturer.all)
  }

   describe '#manufacturer_choices' do

    # CREATE A LIST OF MANUFACTURERS ------------------------------------------------

    let(:create_manufacturer_array) {

      create_manufacturers

      @manufacturer_array ||= Array.new

      @manufacturers = Manufacturer.all

      @count = 0

      @manufacturers.each do |p|

        @count = @count + 1

        @manufacturer_array.push([p.name, @count])
      end
    }

    before(:each) {
     create_manufacturer_array
    }

    it 'return the correct array' do
      expect(@decorated_manufacturer.manufacturer_choices).to eq(@manufacturer_array)
    end
  end

end