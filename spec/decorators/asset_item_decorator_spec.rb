require 'spec_helper'

describe AssetItemDecorator do
  include_context 'asset_setup'

  before(:each) {
    assets_with_users_and_org
    @decorated_asset = @asset_with_org.decorate
  }

  describe 'decoration tests' do
    it 'should be decorated' do
      expect(@decorated_asset).to be_decorated
    end

    it 'should be decorated with an AssetItemDecorator' do
      expect(@decorated_asset).to be_decorated_with AssetItemDecorator
    end
  end

  describe '#condition_string' do
    it 'return the correct string' do
      expect(@decorated_asset.condition_str).to eq("Good")
    end

    it 'return unknown for unmatched value' do
      @decorated_asset.condition = 99
      expect(@decorated_asset.condition_str).to eq("Unknown")
    end
  end

  describe '#condition_choices' do
    let(:choices_array) {[
      ["Excellent", 5],
      ["Very Good", 4],
      ["Good", 3],
      ["Poor", 2],
      ["Very Poor", 1]
    ]}

    it 'return the correct array' do
      expect(@decorated_asset.condition_choices).to eq(choices_array)
    end
  end

  describe '#consequence_str' do
    it 'return the correct string' do
      expect(@decorated_asset.consequence_str).to eq("Moderate")
    end

    it 'return unknown for unmatched value' do
      @decorated_asset.failure_consequence = 99
      expect(@decorated_asset.consequence_str).to eq("Unknown")
    end
  end

  describe '#consequence_choices' do
    let(:consequences_array) {[
      ["Extremely High", 5],
      ["High", 4],
      ["Moderate", 3],
      ["Low", 2],
      ["Very Low", 1]
    ]}

    it 'return the correct array' do
      expect(@decorated_asset.consequence_choices).to eq(consequences_array)
    end
  end

  describe '#failure_str' do
    it 'return the correct string' do
      expect(@decorated_asset.failure_str).to eq("Nominal")
    end

    it 'return unknown for unmatched value' do
      @decorated_asset.failure_probability = 99
      expect(@decorated_asset.failure_str).to eq("Unknown")
    end
  end

  describe '#failure_choices' do
    let(:failures_array) {[
      ["Imminent", 5],
      ["Likely", 4],
      ["Nominal", 3],
      ["Unlikely", 2],
      ["Very Unlikely", 1]
    ]}

    it 'return the correct array' do
      expect(@decorated_asset.failure_choices).to eq(failures_array)
    end
  end

  describe '#google_maps_url' do
    let(:url){ "https://www.google.com/maps/place/#{@decorated_asset.latitude},#{@decorated_asset.longitude}/@#{@decorated_asset.latitude},#{@decorated_asset.longitude},15z/" }

    it 'returns the correct url' do
      expect(@decorated_asset.google_map_url).to eq(url)
    end
  end

  describe '#install_date' do
    it 'should return the correct install date string' do
      expect(@decorated_asset.install_date).to eq("12/01/2014")
    end
  end

  describe '#status_str' do
    it 'return the correct string' do
      expect(@decorated_asset.status_str).to eq("Operational")
    end

    it 'return unknown for unmatched value' do
      @decorated_asset.status = 99
      expect(@decorated_asset.status_str).to eq("Unknown")
    end
  end

  describe '#failure_choices' do
    let(:status_array) {[
      ["Ordered", 1],
      ["In Inventory", 2],
      ["Scheduled Install", 3],
      ["Operational", 4],
      ["Scheduled Replacement", 5],
      ["Removed", 6],
      ["In Maintenance", 7]
    ]}

    it 'return the correct array' do
      expect(@decorated_asset.status_choices).to eq(status_array)
    end
  end


end
