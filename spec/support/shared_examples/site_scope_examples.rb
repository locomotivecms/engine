RSpec.shared_examples_for 'model scoped by a site' do

  let!(:model_site) { model.site }

  it { expect(model).to respond_to(:site) }

  describe 'touch' do

    let(:date) { Time.zone.local(2015, 4, 1, 12, 0, 0) }

    subject { model.save! }

    it 'updates the updated_at attribute of the site' do
      travel_to(date) do
        expect { subject }.to change { model_site.updated_at }.to date
      end
    end

    it 'updates the template_version or content_version attribute of the site' do
      travel_to(date) do
        expect { subject }.to change { model_site.send(attribute) }.to date
      end
    end

  end

end
