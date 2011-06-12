require "bundler/setup"
Bundler.require(:default)

include Twilio

def respond(route, &block)
  action = Proc.new do
    r = Response.new
    r.instance_eval(&block)
    r.respond
  end

  get(route, &action)
  post(route, &action)
end

def valid_password?(password)
  true
end

allowed_numbers = [
  "+1...",       # The buzzer
  "+13127307501" # My phone
]

respond "/buzz" do
  addRedirect("/unlock") and break if Thread.current[:allow_next]

  Thread.current[:password] = nil

  if allowed_numbers.include? params[:From]
    addSay "Hello, if you have a password, please say it after the beep. Otherwise, wait to be forwarded to a person."

    addRecord \
      :action             => "/check_password",
      :playBleep          => true,
      :maxLength          => 10,
      :transcribe         => true,
      :transcribeCallback => "/password?CallID=#{params[:CallSid]}"

    # addRedirect("/forward")

    addSay "Good bye."
    addHangup
  else
    addReject
  end
end

respond "/forward" do
  numbers = %w[3127307501 3127311448 ...]

  dial = Dial.new
  numbers.each { |n| dial.append Number.new(n) }

  append(dial)
end

respond "/password" do
  Thread.current[:password] = {
    :value   => params[:TranscriptionText],
    :success => params[:TranscriptionStatus] == "completed"
  }
end

respond "/check_password" do
  now = Time.now.to_i

  while now < Time.now.to_i + 5
    if password = Thread.current[:password]
      if password[:success]
        if valid_password?(password[:value])
          addRedirect "/unlock"
        else
          addSay "Sorry, that is not a valid password."
          addHangup
        end
      else
        addSay "Sorry, we couldn't understand what you said."
        addHangup
      end
    end
  end

  if params[:attempts] >= 3
    addSay "Sorry, there was a problem."
    addHangup
  else
    addRedirect "/check_password?attempts=#{params[:attempts].to_i + 1}"
  end
end

respond "/unlock" do
  Thread.current[:allow_next] = false
  Thread.current[:password]   = false

  addPlay "http://www.dialabc.com/i/cache/dtmfgen/wavpcm8.300/6.wav"
end

get "/allow_next" do
  Thread.current[:allow_next] = true
end
