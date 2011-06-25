class Ability
  include CanCan::Ability

  ROLES = %w(admin author designer)

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
  end

  def setup_designer_permissions!
    can :manage, Page

    can :manage, ContentInstance

    can :manage, ContentType

    can :manage, ThemeAsset

    can :import, Site

    can :point,  Site

    can :manage, Membership
  end

  def setup_admin_permissions!
    can :manage, :all
  end
end
