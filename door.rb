require "bundler/setup"
Bundler.require(:default)

$: << File.expand_path("./lib")
require "support/redis"
require "support/twilio"

set :redis, ENV['REDISTOGO_URL'] || "redis://127.0.0.1:6379"

respond "/buzz" do
  unlock! and next if allow_next?

  if number_allowed?(params[:From]) or development?
    # addSay "Hello, if you have a password, please say it after the beep. Otherwise, wait to be forwarded to a person."

    # addRecord \
      # :action             => "/check_password_message",
      # :playBeep           => true,
      # :maxLength          => 3
      # # :transcribe         => true,
      # # :transcribeCallback => "/password"


    addGather(:numDigits => 4, :timeout => 3, :action => "/passcode") do
      addSay "If you have a passcode, enter it now. " +
             "Otherwise, wait to be connected to a person"
    end

    forward!
  else
    addReject
  end
end

respond "/passcode" do
  if valid_passcode? params[:Digits]
    unlock!
  else
    addSay "Sorry, that's not a valid passcode."
    forward!
  end
end

respond "/forward" do
  numbers = %w[3127307501 3127311448 3128046488]

  dial = Dial.new
  numbers.each { |n| dial.append Number.new(n) }

  append(dial)
end

respond "/password" do
  if params[:TranscriptionStatus] == "completed"
    attempted_passwords params[:TranscriptionText].downcase.split(/[^a-z]+/)
  end

  # password_attempted!
end

respond "/check_password_message" do
  addSay "Checking..."
  addRedirect "/check_password"
end

respond "/check_password" do
  timeout = Time.now + 5
  locked = true

  while Time.now < timeout
    if valid_password?
      addSay "We are on level 3!"
      unlock!
      locked = false
      break
    end
    sleep 0.1
  end

  if locked
    addSay "Sorry, there was a problem."
    # forward!
  end
end

respond "/unlock" do

  Thread.current[:allow_next] = false
  Thread.current[:password]   = false

  3.times { addPlay "/unlock_tone" }
end

get "/unlock_tone" do
  send_file File.expand_path("./public/6.wav"),
    :type        => "audio/wav",
    :disposition => "attachment",
    :stream      => true
end

get "/allow_next" do
  allow_next!
  "OK"
end
