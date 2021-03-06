ENV['REDIS_URL'] = ENV['REDISTOGO_URL']

require "bundler/setup"
Bundler.require(:default)

$: << File.expand_path("./lib")
require "support/redis"
require "support/twilio"

respond "/buzz" do
  unlock!
end

respond "/forward" do
  dial = Twilio::Dial.new
  dial.append(Twilio::Number.new("+13127307501"))
  dial.append(Twilio::Number.new("+13127311448"))

  append(dial)
end
