class Ability
  include CanCan::Ability

  ROLES = %w(admin designer author)

  def initialize(account, site)
    @account, @site = account, site

    alias_action :index, :show, :edit, :update, :to => :touch

    @membership = @site.memberships.where(:account_id => @account.id).first

    return false if @membership.blank?

    if @membership.admin?
      setup_admin_permissions!
    else
      setup_default_permissions!

      setup_designer_permissions! if @membership.designer?

      setup_author_permissions!  if @membership.author?
    end
  end

  def setup_default_permissions!
    cannot :manage, :all
  end

  def setup_author_permissions!
    can :touch, [Page, ThemeAsset]
    can :sort, Page

    can :manage, [ContentInstance, Asset]

    can :touch, Site do |site|
      site == @site
    end
  end

  def setup_designer_permissions!
    can :manage, Page

    can :manage, ContentInstance

    can :manage, ContentType

    can :manage, Snippet

    can :manage, ThemeAsset

    can :manage, Asset

    can :manage, Site do |site|
      site == @site
    end

    can :import, Site

    can :export, Site

    can :point, Site

    cannot :create, Site

    can :manage, Membership

    cannot :change_role, Membership do |membership|
      @membership.account_id == membership.account_id || # can not edit myself
      membership.admin? # can not modify an administrator
    end
  end

  def setup_admin_permissions!
    can :manage, :all

    cannot :change_role, Membership do |membership|
      @membership.account_id == membership.account_id # can not edit myself
    end
  end
end
