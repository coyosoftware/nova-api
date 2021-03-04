RSpec.describe Nova::API::SearchParams::ThirdParty do
  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:q, Dry::Types['coercible.string'].optional) }
  end
end
