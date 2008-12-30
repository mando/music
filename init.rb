require 'uri'
require 'rubygems'
require File.join(File.dirname(__FILE__), 'lib', 'sinatra_uri_char_fix')
require 'sinatra'
require File.join(File.dirname(__FILE__) + 'lib', 'config')

# Specify files that should be hidden from lists. i.e.: album.jpg is a special
# file used within the UI, and should not be included in an album track list.
HIDE_LIST = ['lost+found', 'album.jpg']

helpers do
  # No funny business. Send 'em home if the path isn't found.
  def get_entries(path)
    redirect '/' unless File.exist? path
    Dir.entries(path).reject {|e| e =~ /^\./}.sort - HIDE_LIST
  end
  
  def get_mp3(path)
    throw :halt , '' unless File.exist? path
    IO.read(path)
  end
  
  def get_album_jpg(path)
    throw :halt, IO.read(File.join(File.dirname(__FILE__), 'public', 'image', 'album2.jpg')) unless File.exist? path
    IO.read(path)
  end
  
  def title
    ['MUSIC', params[:artist], params[:album]].compact.join(': ')
  end
  
  def url_for(*args)
    '/' + args.map {|e| URI.escape(e) }.join('/')
  end
end


get '/' do
  @entries = Dir.entries(MUSIC_BASE).reject {|e| e =~ /^\./}.sort
  erb :index
end

get '/:artist/:album/album.jpg' do
  get_album_jpg(File.join(MUSIC_BASE, params[:artist], params[:album], 'album.jpg'))
end

get '/:artist/:album/:song' do
  get_mp3(MUSIC_BASE + "/#{params[:artist]}/#{params[:album]}/#{params[:song]}")
end

get '/:artist/:album' do
  @entries = get_entries(MUSIC_BASE + "/#{params[:artist]}/#{params[:album]}")
  erb :album, :layout => false
end

get '/:artist' do
  @entries = get_entries(MUSIC_BASE + "/#{params[:artist]}")
  erb :artist
end
