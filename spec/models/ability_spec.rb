require 'spec_helper'

describe Ability do

  before :each do
    @site = FactoryGirl.create(:site)
    @account = FactoryGirl.create(:account)

    @admin  = FactoryGirl.create(:membership, :account => FactoryGirl.build(:account), :site => FactoryGirl.build(:site))
    @designer  = FactoryGirl.create(:membership, :account => FactoryGirl.build(:account), :site => @site, :role => %(designer))
    @author = FactoryGirl.create(:membership, :account => FactoryGirl.build(:account), :site => @site, :role => %(author))
  end

  context 'pages' do

    subject { Page.new }

    context 'management' do
      it 'should allow management of pages from (admin, designer, author)' do
        should     allow_permission_from :manage, @admin
        should     allow_permission_from :manage, @designer
        should_not allow_permission_from :manage, @author
      end
    end

    context 'touching' do
      it 'should allow touching of pages from (author)' do
        should allow_permission_from :touch, @author
      end
    end

  end

  context 'content instance' do

    subject { ContentInstance.new }

    context 'management' do
      it 'should allow management of pages from (admin, designer, author)' do
        should allow_permission_from :manage, @admin
        should allow_permission_from :manage, @designer
        should allow_permission_from :manage, @author
      end
    end

  end

  context 'content type' do

    subject { ContentType.new }

    context 'management' do
      it 'should allow management of pages from (admin, designer)' do
        should     allow_permission_from :manage, @admin
        should     allow_permission_from :manage, @designer
        should_not allow_permission_from :manage, @author
      end
    end

    # context 'touching' do
    #   it 'should allow touching of pages from (author)' do
    #     should_not allow_permission_from :touch, @author
    #   end
    # end

  end

  context 'theme assets' do

    subject { ThemeAsset.new }

    context 'management' do
      it 'should allow management of pages from (admin, designer)' do
        should     allow_permission_from :manage, @admin
        should     allow_permission_from :manage, @designer
        should_not allow_permission_from :manage, @author
      end
    end

    context 'touching' do
      it 'should allow touching of pages from (author)' do
        should allow_permission_from :touch, @author
      end
    end

  end

  context 'site' do

    subject { Site.new }

    context 'management' do
      it 'should allow management of pages from (admin)' do
        should     allow_permission_from :manage, @admin
        should_not allow_permission_from :manage, @designer
        should_not allow_permission_from :manage, @author
      end
    end

    context 'importing' do
      it 'should allow importing of sites from (designer)' do
        should     allow_permission_from :import, @designer
        should_not allow_permission_from :import, @author
      end
    end

    context 'pointing' do
      it 'should allow importing of sites from (designer)' do
        should     allow_permission_from :point, @designer
        should_not allow_permission_from :point, @author
      end
    end

  end

  context 'membership' do

    subject { Membership.new }

    context 'management' do
      it 'should allow management of memberships from (admin, designer)' do
        should     allow_permission_from :manage, @admin
        should     allow_permission_from :manage, @designer
        should_not allow_permission_from :manage, @author
      end
    end

  end

end
