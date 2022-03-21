class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!

  def landing_page
    set_meta_tags title: 'Home'
  end

  def pricing
    set_meta_tags title: action_name.capitalize
  end

  def privacy
    set_meta_tags title: action_name.capitalize
  end

  def terms
    set_meta_tags title: action_name.capitalize
  end
end
