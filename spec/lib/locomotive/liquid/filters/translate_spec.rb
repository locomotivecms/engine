require 'spec_helper'

describe Locomotive::Liquid::Filters::Translate do
  let(:site)     { FactoryGirl.create(:site) }
  let(:context)  { Liquid::Context.new({}, {}, {:site => site}) }
  let(:template) { Liquid::Template.parse("{{ 'example_text' | translate }}") }
  subject { template.render(context) }
  
  describe '#translate' do
    before do
      values = {
        en: 'Example text', es: 'Texto de ejemplo'
      }
      FactoryGirl.create(:translation, site: site, key: 'example_text', values: values)
    end
    
    it "uses default locale " do
      should == "Example text"
    end
    
    context "specifying a locale" do
      let(:template) { Liquid::Template.parse("{{ 'example_text' | translate:'es' }}") }
      
      it "translates" do
        should == "Texto de ejemplo"
      end
    end
    
    context "specifying a locale that doesn't exist" do
      let(:template) { Liquid::Template.parse("{{ 'example_text' | translate [locale: nl] }}") }
      
      it "reverts to default locale" do
        should == "Example text"
      end
    end
    
    context "with a different global locale" do
      before do
        I18n.locale = :es
      end
      
      after do
        I18n.locale = :en
      end
      it "translates" do
        should == "Texto de ejemplo"
      end
    end
  end
end
