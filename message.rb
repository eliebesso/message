require 'sinatra'
require 'sinatra/reloader' if development?
require 'tilt/erubis'
 

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, escape_html: true
end

before do
  session[:messages] ||= []
end

helpers do
  def get_day(time)
    time.strftime('%m/%d/%Y')
  end

  def truncate(field)
    field[0, 20]
  end
end

def field_size?(field, characters)
  !(1..characters).cover? field.size
end

get '/' do
  redirect '/new'
end

get '/new' do
  erb :new, layout: :layout
end

post '/new' do
  message = params[:message].strip
  author = params[:author].strip
  if field_size?(message, 140) && field_size?(author, 30)
    session[:error] = 'Your message must have 1 to 140 characters and your name
    must have 1 to 30 characters.'
    redirect '/new'
  elsif field_size?(message, 140)
    session[:error] = 'Your message must have 1 to 140 characters.'
    redirect '/new'
  elsif field_size?(author, 30)
    session[:error] = 'Your name must have 1 to 30 characters.'
    redirect '/new'
  else
    session[:messages] << { message: params[:message], author: params[:author],
                            time: Time.new }
    session[:success] = 'You have just created a message.'
    redirect '/messages'
  end
end

get '/messages' do
  @messages = session[:messages]
  erb :messages, layout: :layout
end

get '/message/:id/edit' do
  id = params[:id].to_i
  @message = session[:messages][id]
  erb :message
end

post '/message/:id/edit' do
  message = params[:message].strip
  author = params[:author].strip
  id = params[:id].to_i
  @message = session[:messages][id]

  if field_size?(message, 140) && field_size?(author, 30)
    session[:error] = "The message hasn't been updated, your message must have
    1 to 140 characters and your name
    must have 1 to 30 characters."
  elsif field_size?(message, 140)
    session[:error] = "The message hasn't been updated,
    it must have 1 to 140 characters."
  elsif field_size?(author, 30)
    session[:error] = "The message hasn't been updated,
    the author name must have 1 to 30 characters."
  else
    @message[:message] = message
    @message[:author] = author
    session[:success] = 'You have just edited the message.'
  end

  redirect '/messages'
end

post '/message/:id/destroy' do
  id = params[:id].to_i
  session[:messages].delete_at(id)
  session[:success] = 'You have just deleted a message.'
  redirect '/messages'
end
