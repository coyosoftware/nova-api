RSpec.describe Nova::API::SearchParams::CurrentAsset do
  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:company_id, Dry::Types['coercible.integer'].optional) }
    it { is_expected.to have_attribute(:with_inactive, Dry::Types['strict.bool'].optional) }
  end
end
