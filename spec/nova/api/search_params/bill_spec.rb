RSpec.describe Nova::API::SearchParams::Bill do
  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:identifier, Dry::Types['coercible.string'].optional) }
  end
end
