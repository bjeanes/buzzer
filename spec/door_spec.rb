require File.dirname(__FILE__) + "/spec_helper"

describe "Door Buzzer App" do
  let(:app) { Class.new(Sinatra::Application) }

  describe "/buzz" do
    context "invalid number" do
      it "rejects the call" do
        get("/buzz").body.should =~ /^<Response><Reject>/
      end
    end

    context "valid number" do
      let(:number) { app.redis.srandmember('allowed-numbers') }

      it "does not reject the call" do
        get("/buzz", :From => number).body.should_not =~ /<Reject/
      end
    end
  end
end
