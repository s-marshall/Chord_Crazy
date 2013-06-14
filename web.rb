require 'sinatra'
require 'haml'

get '/' do
	haml :triads
end
