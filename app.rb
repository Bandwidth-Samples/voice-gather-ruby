require 'sinatra'
require 'bandwidth-sdk'

begin
  BW_ACCOUNT_ID = ENV.fetch('BW_ACCOUNT_ID')
  BW_CLIENT_ID = ENV.fetch('BW_CLIENT_ID')
  BW_CLIENT_SECRET = ENV.fetch('BW_CLIENT_SECRET')
  BW_VOICE_APPLICATION_ID = ENV.fetch('BW_VOICE_APPLICATION_ID')
  BW_NUMBER = ENV.fetch('BW_NUMBER')
  BASE_CALLBACK_URL = ENV.fetch('BASE_CALLBACK_URL')
  LOCAL_PORT = Integer(ENV.fetch('LOCAL_PORT'))
rescue StandardError
  puts 'Please set the environmental variables defined in the README'
  exit(-1)
end

set :port, LOCAL_PORT
set :host_authorization, permitted_hosts: []

Bandwidth.configure do |config|
  config.client_id = BW_CLIENT_ID
  config.client_secret = BW_CLIENT_SECRET
end

def parse_body
  data = JSON.parse(request.body.read)
  halt 400 unless data.is_a?(Hash)
  data
rescue JSON::ParserError
  halt 400
end

post '/calls' do
  data = parse_body
  halt 400 unless data['to'].is_a?(String)

  call_body = Bandwidth::CreateCall.new(
    application_id: BW_VOICE_APPLICATION_ID,
    to: data['to'],
    from: BW_NUMBER,
    answer_url: "#{BASE_CALLBACK_URL}/callbacks/outbound/voice"
  )

  begin
    Bandwidth::CallsApi.new.create_call(BW_ACCOUNT_ID, call_body)
  rescue StandardError => e
    warn "Failed to create call: #{e.message}"
    halt 500
  end

  status 200
end

post '/callbacks/outbound/voice' do
  data = parse_body

  response = Bandwidth::Bxml::Response.new

  case data['eventType']
  when 'answer'
    speak_sentence = Bandwidth::Bxml::SpeakSentence.new('Press 1 to choose option 1. Press 2 to choose option 2. Press pound when you are finished.')
    gather = Bandwidth::Bxml::Gather.new([speak_sentence], {
                                           gather_url: '/callbacks/outbound/voice/gather',
                                           terminating_digits: '#'
                                         })
    response.add_verbs(gather)
  when 'initiate'
    speak_sentence = Bandwidth::Bxml::SpeakSentence.new('Initiate event received but not intended. Ending call.')
    hangup = Bandwidth::Bxml::Hangup.new
    response.add_verbs([speak_sentence, hangup])
  when 'disconnect'
    puts "Call #{data['callId']} has disconnected"
  else
    puts "Unexpected event type #{data['eventType']} received"
  end

  content_type 'application/xml'
  response.to_bxml
end

post '/callbacks/outbound/voice/gather' do
  data = parse_body
  halt 400 unless data['eventType'] == 'gather'

  speak_sentence = case data['digits']
                   when '1'
                     Bandwidth::Bxml::SpeakSentence.new('You chose option 1. Goodbye.')
                   when '2'
                     Bandwidth::Bxml::SpeakSentence.new('You chose option 2. Goodbye.')
                   else
                     Bandwidth::Bxml::SpeakSentence.new('You did not choose a valid option. Goodbye.')
                   end

  content_type 'application/xml'
  Bandwidth::Bxml::Response.new([speak_sentence]).to_bxml
end
