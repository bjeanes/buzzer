require "uri"
include Twilio

class Twilio::Response
  def to_s
    respond
  end
end

def respond(route, options = {}, &block)
  any(route, options) do
    instance_eval(&block)
    twilio.to_s
  end
end

helpers do
  def twilio
    @twilio ||= Response.new
  end

  def unlock!
    clear_attempted_passwords!
    addRedirect "/unlock"
  end

  def forward!
    addSay "Forwarding you now..."
    addRedirect "/forward"
  end

  def addSay(text, options = {})
    twilio.addSay(text, {:voice => "woman"}.merge(options))
  end

  def method_missing(m,*a,&b)
    twilio.send(m,*a,&b)
  rescue
    super
  end
end
