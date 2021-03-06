class HomeController < ApplicationController

  def index
    @posts = Post.all.order(created_at: :desc).limit(4)

    to  = Time.current.at_end_of_day
    from    = (to - 6.day).at_beginning_of_day
    posts_weekly = Post.where(created_at: from...to)
    posts_likes_weekly_desc = posts_weekly.includes(:liked_users).sort {|a,b| b.liked_users.size <=> a.liked_users.size}
    @posts_likes_weekly = posts_likes_weekly_desc.first(4)

    posts_likes_all_time_desc = Post.includes(:liked_users).sort {|a,b| b.liked_users.size <=> a.liked_users.size}
    @posts_likes_all_time = posts_likes_all_time_desc.first(4)


    agent = Mechanize.new
    #ローソン
    from_lawson = agent.get("https://www.lawson.co.jp/recommend/original/dessert/")
    @lawson_new_items = from_lawson.search('article#dessert li').first(4)

    #ファミマ
    from_famima = agent.get("https://www.family.co.jp/goods/dessert.html")
    @famima_new_items = from_famima.search('div.ly-list-goods .ly-mod-layout-clm a').first(4)

    if user_signed_in?
      @followings_new_posts = Post.where(user_id: current_user.following_ids).order(created_at: :desc).limit(4)
    end
  end
end
