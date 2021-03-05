RSpec.describe Nova::API::SearchParams::CurrentAssetStatement do
  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:company_id, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:current_asset_id, Dry::Types['coercible.integer']) }
    it { is_expected.to have_attribute(:initial_date, Dry::Types['coercible.string'].constrained(format: described_class::DATE_REGEX)) }
    it { is_expected.to have_attribute(:final_date, Dry::Types['coercible.string'].constrained(format: described_class::DATE_REGEX)) }
  end
end
