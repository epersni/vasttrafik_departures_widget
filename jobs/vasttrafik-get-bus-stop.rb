require 'net/http'
require 'uri'
require 'openssl'
require 'json'

STOP_ID="9021014003830000"
AUTH_KEY="your-key-here"
STOP_NAME="Kippholmen, Göteborg"

MINUTES_PER_DAY = 24*60
MAX_NUMBER_OF_DEPARTURES = 5

def time_elapsed(start_str, finish_str)
  start_mins = time_str_to_minutes(start_str)  
  finish_mins = time_str_to_minutes(finish_str)
  finish_mins += MINUTES_PER_DAY if
    finish_mins < start_mins
  (finish_mins-start_mins)
end

def time_str_to_minutes(str)
  hrs, mins = str.split(':').map(&:to_i)
  60 * hrs + mins
end


SCHEDULER.every '3m', :first_in => 0 do |job| 
  uri = URI.parse("https://api.vasttrafik.se:443/token")
  request = Net::HTTP::Post.new(uri)
  request["Authorization"] = "Basic #{AUTH_KEY}"
  request.set_form_data( "grant_type" => "client_credentials", )
  req_options = { use_ssl: uri.scheme == "https", verify_mode: OpenSSL::SSL::VERIFY_NONE, }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end

  token = JSON.parse(response.body)['access_token']

  date = Time.now().strftime("%y-%m-%d")
  time = Time.now().strftime("%H:%M")

  uri = URI.parse("https://api.vasttrafik.se/bin/rest.exe/v2/departureBoard?id=#{STOP_ID}&date=#{date}&time=#{time}&format=json")
  request = Net::HTTP::Get.new(uri)
  request["Authorization"] = "Bearer #{token}"
  req_options = { use_ssl: uri.scheme == "https", }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do 
    |http| http.request(request) 
  end 

  departureBoard = JSON.parse(response.body)['DepartureBoard']

  departures_from_response = departureBoard['Departure'].first(MAX_NUMBER_OF_DEPARTURES)

  departures_list = []

  if departures_from_response.length > 0
    server_time = departureBoard['servertime']
    
    departureBoard['Departure'].first(MAX_NUMBER_OF_DEPARTURES).each do |child|
        eta = time_elapsed(server_time, child['time']).to_s + " min"
        departures_list.push({
          name: child['sname'],
          time: child['time'],
          eta: eta,
          fgColor: child['fgColor'],
          bgColor: child['bgColor'],
          direction: child['direction']
        })
    end

  send_event('vasttrafik_departure_board',
             { header: "#{STOP_NAME}",
               departures: departures_list})  
	end
end

