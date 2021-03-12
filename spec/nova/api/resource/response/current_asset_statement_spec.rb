RSpec.describe Nova::API::Resource::Response::CurrentAssetStatement do
  describe 'attributes' do
    subject { described_class }

    it { is_expected.to have_attribute(:last_statement, Dry::Types['coercible.float'].optional) }
    it { is_expected.to have_attribute(:write_offs, Dry::Types['strict.array'].of(Nova::API::Resource::WriteOff).optional) }
  end
end
