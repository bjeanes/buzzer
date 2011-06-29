require "uri"

helpers do
  def unlock!
    clear_attempted_passwords!
    addRedirect "/unlock"
  end

  def forward!
    addSay "Forwarding you now..."
    addRedirect "/forward"
  end

  # def addSay(text, options = {})
    # super(text, {:voice => "woman"}.merge(options))
  # end
end
