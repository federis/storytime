require 'spec_helper'

describe "In the dashboard, Posts" do
  before{ login_admin }

  it "lists posts" do
    3.times{ FactoryGirl.create(:post) }
    FactoryGirl.create(:post, post_type: FactoryGirl.create(:post_type, excluded_from_primary_feed: false))
    static_page = FactoryGirl.create(:page)
    visit dashboard_posts_path
    
    within "#list" do
      Storytime::Post.primary_feed.each do |p|
        expect(page).to have_content(p.title)
      end

      expect(page).not_to have_content(static_page.title)
    end
  end
  
  it "creates a post" do
    Storytime::Post.count.should == 0
    media = FactoryGirl.create(:media)

    visit new_dashboard_post_path
    fill_in "post_title", with: "The Story"
    fill_in "post_excerpt", with: "It was a dark and stormy night..."
    fill_in "post_draft_content", with: "It was a dark and stormy night..."
    find("#featured_media_id").set media.id
    click_button "Create Blog"
    
    page.should have_content(I18n.t('flash.posts.create.success'))
    Storytime::Post.count.should == 1

    post = Storytime::Post.last
    post.title.should == "The Story"
    post.draft_content.should == "It was a dark and stormy night..."
    post.user.should == current_user
    post.should_not be_published
    post.post_type.should == Storytime::PostType.default_type
    post.featured_media.should == media
  end

  it "updates a post" do
    post = FactoryGirl.create(:post, published_at: nil)
    original_creator = post.user
    Storytime::Post.count.should == 1

    visit edit_dashboard_post_path(post)
    fill_in "post_title", with: "The Story"
    fill_in "post_draft_content", with: "It was a dark and stormy night..."
    click_button "Update Blog"
    
    page.should have_content(I18n.t('flash.posts.update.success'))
    Storytime::Post.count.should == 1

    post = Storytime::Post.last
    post.title.should == "The Story"
    post.draft_content.should == "It was a dark and stormy night..."
    post.user.should == original_creator
    post.should_not be_published
  end

  it "deletes a post", js: true do
    3.times{|i| FactoryGirl.create(:post) }
    visit dashboard_posts_path
    p1 = Storytime::Post.first
    p2 = Storytime::Post.last
    click_link("delete_post_#{p1.id}")

    page.should_not have_content(p1.title)
    page.should have_content(p2.title)

    expect{ p1.reload }.to raise_error
  end
  
end
