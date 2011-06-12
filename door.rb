require "bundler/setup"
Bundler.require(:default)

include Twilio

def respond(&block)
  r = Response.new
  r.instance_eval(&block)
  r.respond
end

get "/buzz" do
  respond do
    addSay "Hello, if you have a password, please say it now. Otherwise, wait to be forwarded to a person."
    addPlay "http://www.dialabc.com/i/cache/dtmfgen/wavpcm8.300/6.wav"
  end
end

