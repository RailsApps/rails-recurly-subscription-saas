require 'spec_helper'

describe "Config Variables" do

  describe "Recurly.api_key" do

    it "should be set" do
      Recurly.api_key.should_not eq("recurly_api_key"),
        "Your Recurly.api_key is not set, Please refer to the 'Configure the Recurly Initializer' section of the README"
    end

  end

  describe "Recurly.js.private_key" do

    it "should be set" do
      Recurly.js.private_key.should_not eq("recurly_js_private_key"),
        "Your Recurly.js.private_key is not set, Please refer to the 'Configure the Recurly Initializer' section of the README"
    end

  end

end
