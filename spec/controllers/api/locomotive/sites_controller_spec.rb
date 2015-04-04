# require 'spec_helper'

# module Locomotive
#   module Api
#     describe SitesController do

#       let(:site)        { create(:site, domains: %w{www.acme.com}) }
#       let(:site_bis)    { create('another site') }
#       let(:super_admin) { false }
#       let(:account)     { create(:account, super_admin: super_admin) }

#       let!(:membership) do
#         create(:membership, account: account, site: site, role: 'admin')
#       end

#       context 'super_admin authenticated' do
#         let(:super_admin) { true }

#         before do
#           request_site site
#           site_bis
#           sign_in account
#         end

#         describe "#GET index" do
#           subject { get(:index, locale: :en, format: :json) }
#           it { is_expected.to be_success }
#           specify do
#             subject
#             expect(assigns(:sites).to_a).to eq([site, site_bis])
#           end
#         end

#         describe "#GET show" do
#           subject { get :show, id: site._id, locale: :en, format: :json }
#           it { is_expected.to be_success }

#           context 'a site not owned by the current account' do
#             subject { get :show, id: site_bis._id, locale: :en, format: :json }
#             it { is_expected.to be_success }
#           end
#         end

#       end

#       context 'simple local admin authenticated' do

#         before do
#           request_site site
#           sign_in account
#         end

#         describe "#GET index" do
#           subject { get(:index, locale: :en, format: :json) }
#           it { is_expected.to be_success }
#           specify do
#             subject
#             expect(assigns(:sites).to_a).to eq([site])
#           end
#         end

#         describe "#GET show" do
#           subject { get :show, id: site._id, locale: :en, format: :json }
#           it { is_expected.to be_success }

#           context 'a site not owned by the current account' do
#             subject { get :show, id: site_bis._id, locale: :en, format: :json }
#             it { is_expected.to_not be_success }
#           end
#         end

#         describe "#POST create" do
#           subject do
#             post :create, locale: :en, site: { handle: generate(:handle), name: generate(:name) },
#               format: :json
#           end
#           it { is_expected.to be_success }
#           specify do
#             expect { subject }.to change(Locomotive::Site, :count).by(+1)
#           end
#         end

#         describe "#PUT update" do
#           let(:new_name) { generate(:name) }
#           subject do
#             put :update, id: site.id, locale: :en, site: { name: new_name }, format: :json
#           end
#           it { is_expected.to be_success }
#           specify do
#             expect(JSON.parse(subject.body).fetch('name')).to eq(new_name)
#           end
#         end

#         describe "#DELETE destroy" do
#           subject do
#             delete :destroy, id: site.id, locale: :en, format: :json
#           end
#           it { is_expected.to be_success }
#           specify do
#             expect { subject }.to change(Locomotive::Site, :count).by(-1)
#           end
#         end

#       end

#     end
#   end
# end
