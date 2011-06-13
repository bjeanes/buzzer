[
  "+13122666880", # The buzzer
  "+13128046488", # Home phone
  "+13127307501"  # My phone
].each do |number|
  redis.sadd("allowed-numbers", number)
end

if development?
  redis.sadd("passwords", "password")
end

helpers do
  def number_allowed?(number)
    redis.sismember("allowed-numbers", number.to_s)
  end

  def valid_passcode?(digits)
    digits == "1234"
  end

  def valid_password?
    redis.sinter("passwords", "attempted-passwords").size > 0
  end

  def clear_attempted_passwords!
    redis.del("attempted-passwords")
  end

  def attempted_passwords(passwords)
    clear_attempted_passwords!
    passwords.each do |password|
      redis.sadd("attempted-passwords", password)
    end
  end

  def allow_next!
    redis.set("allow-next", "1")
  end

  def allow_next?
    redis.getset("allow-next", "0") == "1"
  end
end
