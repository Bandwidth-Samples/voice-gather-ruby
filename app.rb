require 'sinatra'
require 'bandwidth-sdk'

begin
  BW_USERNAME = ENV.fetch('BW_USERNAME')
  BW_PASSWORD = ENV.fetch('BW_PASSWORD')
  BW_ACCOUNT_ID = ENV.fetch('BW_ACCOUNT_ID')
  BW_VOICE_APPLICATION_ID = ENV.fetch('BW_VOICE_APPLICATION_ID')
  BW_NUMBER = ENV.fetch('BW_NUMBER')
  USER_NUMBER = ENV.fetch('USER_NUMBER')
  LOCAL_PORT = ENV.fetch('LOCAL_PORT')
  BASE_CALLBACK_URL = ENV.fetch('BASE_CALLBACK_URL')
rescue StandardError
  puts 'Please set the environmental variables defined in the README'
  exit(-1)
end

set :port, LOCAL_PORT

Bandwidth.configure do |config| # Configure Basic Auth
  config.username = BW_USERNAME
  config.password = BW_PASSWORD
end

post '/calls' do
  data = JSON.parse(request.body.read)
  call_body = Bandwidth::CreateCall.new(
    application_id: BW_VOICE_APPLICATION_ID,
    to: data['to'],
    from: BW_NUMBER,
    answer_url: "#{BASE_CALLBACK_URL}/callbacks/outbound/voice"
  )

  calls_api_instance = Bandwidth::CallsApi.new
  calls_api_instance.create_call(BW_ACCOUNT_ID, call_body)

  return 200
end

post '/callbacks/outbound/voice' do
  data = JSON.parse(request.body.read)

  response = Bandwidth::Bxml::Response.new

  case data['eventType']
  when 'answer'
    speak_sentence = Bandwidth::Bxml::SpeakSentence.new('Press 1 to choose option 1. Press 2 to choose option 2. Press pound when you are finished.')
    gather = Bandwidth::Bxml::Gather.new([speak_sentence], {
                                           gather_url: "#{BASE_CALLBACK_URL}/callbacks/outbound/gather",
                                           terminating_digits: '#'
                                         })
    response.add_verb(gather)
  when 'initiate'
    speak_sentence = Bandwidth::Bxml::SpeakSentence.new('Initiate event received but not intended. Ending call.')
    hangup = Bandwidth::Bxml::Hangup.new
    response.add_verb([speak_sentence, hangup])
  when 'disconnect'
    puts 'The Disconnect event is fired when a call ends, for any reason.'
    puts "Call #{data['callId']} has disconnected"
  else
    puts "Unexpected event type #{data['eventType']} received"
  end

  return response.to_bxml
end

post '/callbacks/outbound/gather' do
  data = JSON.parse(request.body.read)

  response = Bandwidth::Bxml::Response.new

  if data['eventType'] == 'gather'
    digits = data['digits']

    speak_sentence = if digits == '1'
                       Bandwidth::Bxml::SpeakSentence.new('You chose option 1. Goodbye.')
                     elsif digits == '2'
                       Bandwidth::Bxml::SpeakSentence.new('You chose option 2. Goodbye.')
                     else
                       Bandwidth::Bxml::SpeakSentence.new('You did not choose a valid option. Goodbye.')
                     end
    response.add_verb([speak_sentence])
  end

  return response.to_bxml
end
