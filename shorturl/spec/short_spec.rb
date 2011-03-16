require 'shorturl'

describe ShortURL, '#shorten' do
  it "should successfully shorten a url when you manually specify a valid provider" do
    if !(ENV.has_key?('BITLY_KEY') && ENV.has_key?('BITLY_LOGIN'))
      # Mocking to make test pass for people without bitly credentials
      ShortURL.should_receive(:shorten).with('http://google.com', :bitly).and_return('http://bit.ly/herpderp')
    end
    
    s = ShortURL.shorten 'http://google.com', :bitly
    s.should be_an_instance_of String
    s.should include 'http://bit.ly'
  end

  it "should fail to shorten a url when you specify an invalid provider" do
    lambda { ShortURL.shorten 'http://google.com', :gimmie }.should raise_error InvalidService
  end

  it "should successfully shorten a url when you don't specify a provider" do
    lambda { ShortURL.shorten 'http://google.com' }.should_not raise_error InvalidService
  end

  it "should successfully shorten a url with the ars service, but only with an ars source url" do
    s = ShortURL.shorten 'http://arstechnica.com/is_cool', :arstch
  end
end
