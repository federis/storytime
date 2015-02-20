module Storytime
  module Dashboard
    class BlogPostsController < PostsController
      
    private
      def current_post_type
        @current_post_type ||= Storytime::BlogPost
      end
      helper_method :current_post_type

      def load_posts
        @posts = policy_scope(Storytime::Post).page(params[:page_number]).per(10)
        @posts = @posts.primary_feed

        @posts = if params[:published].present? && params[:published] == 'true'
          @posts.published.order(published_at: :desc)
        else
          @posts.draft.order(updated_at: :desc)
        end
      end
    end
  end
end