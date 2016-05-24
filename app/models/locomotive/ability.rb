module Locomotive
  class Ability
    include CanCan::Ability

    ROLES = %w(admin designer author consumer)

    def initialize(account, site)
      @account, @site = account, site

      alias_action :index, :show, :edit, :update, to: :touch

      if @site
        @membership = @site.memberships.where(account_id: @account.id).first
      elsif @account.admin?
        @membership = Membership.new(account: @account, role: 'admin')
      end

      if @membership.nil?
        setup_account_without_a_site
      elsif @membership.admin?
        setup_admin_permissions!
      else
        setup_default_permissions!

        setup_designer_permissions! if @membership.designer?

        setup_author_permissions!  if @membership.author?
        
        setup_consumer_permissions! if @membership.consumer?
      end
    end

    def setup_account_without_a_site
      cannot :manage, :all

      can :create, Site
    end

    def setup_default_permissions!
      cannot :manage, :all
    end

    def setup_author_permissions!
      can :touch, ThemeAsset

      can [:read, :create, :update], Page
      cannot :destroy, Page
      cannot :customize, Page

      can :manage, [ContentEntry, ContentAsset, Translation]

      can :touch, Site, _id: @site._id

      can :read, ContentType
    end

    def setup_designer_permissions!
      can :manage, Page

      can :manage, ContentEntry

      can :manage, ContentType

      can :manage, Snippet

      can :manage, ThemeAsset

      can :manage, ContentAsset

      can :manage, Translation

      can :manage, Site, _id: @site._id

      can :point, Site

      cannot :create, Site

      can :manage, Membership

      cannot :grant_admin, Membership

      cannot [:update, :destroy], Membership do |membership|
        @membership.account_id == membership.account_id || # can not edit myself
        membership.admin? # can not modify an administrator
      end
    end
    
    def setup_consumer_permissions!
      can :read, [Page, ContentEntry, ContentType, ContentAsset, Translation]
      
      can :read, Site, _id: @site._id
    end

    def setup_admin_permissions!
      can :manage, :all

      cannot [:update, :destroy], Membership do |membership|
        @membership.account_id == membership.account_id # can not edit myself
      end
    end
  end
end
