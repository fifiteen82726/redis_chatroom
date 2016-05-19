class ChatsController < ApplicationController
  def login #get/post
    unless request.get? #這樣可以區分是get 還是post
      session["name"] = params[:name] #如果不是get的話這個會跑
      redirect_to :action => :index
    end
  end

  def index #get
    unless session[:name]
      redirect_to :action => 'login'
      return  #避免double render !!!!!重要
    end
  end

  def ajax #get/post

    if request.post?
      timestamp = params[:timestamp].to_i
      msg = params[:msg]
      name = session[:name]
      $redis.zadd('chat_room', timestamp, '#{name} : #{msg}')
      reder :json => {:status => 'success '}

    else

      timestamp = params[:timestamp].to_i
      msg =[]
      $redis.zrange('chat_room', timestamp+1, Time.now.to_i, {withscores:true}).each do |source|
        #格式是 ["JC : yoo" , timestamp]
        msg << [source[1].to_i , source[0]]
      #ap msg
      end
      render :json =>msg.to_json

    end
  end
end