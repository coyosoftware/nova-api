RSpec.describe Nova::API::SearchParams::Apportionment do
  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:q, Dry::Types['coercible.string'].optional) }
    it { is_expected.to have_attribute(:with_deleted, Dry::Types['strict.bool'].optional) }
  end
end
