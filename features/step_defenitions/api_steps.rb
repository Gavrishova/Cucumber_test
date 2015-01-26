require 'json'
require 'jsonpath'
require 'net/http'
require 'nokogiri'
require 'uri'

DEFAULT_HOST = "https://hapi.onetwotrip.com/api"

@http_params = {}

def hash_to_query(hash)
  hash.map{|k,v| "#{k}=#{v}"}.join("&")
end

Given /^I set headers:$/ do |headers|
  @headers = headers
end

Given /^I send and accept (XML|JSON)$/ do |type|
  @headers = {'Accept' => "application/#{type.downcase}", 'Content-Type' => "application/#{type.downcase}"}
end

Given /^I send and accept HTML$/ do
  @headers = {'Accept' => "text/html", 'Content-Type' => "application/x-www-form-urlencoded"}
end

Given /^I add http parameters:$/ do |*args|
  value = args.shift
  if (!@http_params)
    @http_params = {}
  end

  unless value.nil?
    if value.class == Cucumber::Ast::Table
      @http_params.merge!(value.rows_hash)
    else
      @http_params.merge!(JSON.parse(value))
    end
  end
end

# When /^I authenticate as the user "([^"]*)" with the password "([^"]*)"$/ do |user, pass| end

# When /^I digest\-authenticate as the user "(.*?)" with the password "(.*?)"$/ do |user, pass| end

When /^I send a (GET|POST|PUT|DELETE) request (?:for|to) "([^"]*)"(?: with the following:)?$/ do |*args|
  request_type = args.shift
  path = args.shift
  input = args.shift

  data = {}

  unless input.nil?
    if input.class == Cucumber::Ast::Table
      data = input.rows_hash
    else
      data = JSON.parse(input)
    end
  end

  if (@http_params)
    data.merge!(@http_params)
  end

  uri = URI(DEFAULT_HOST + path)
  http = Net::HTTP.new(uri.host, uri.port)
  #debug request
  #http.set_debug_output($stdout)
  http.use_ssl = true

  case request_type
    when 'POST'
      @response = http.post(uri.path, data.to_json, @headers)
    when 'GET'
      @response = http.get(uri.path + '?' + hash_to_query(data), @headers)
    when 'DELETE'
      @response = http.request(Net::HTTP::Delete.new(uri.path, @headers), data.to_json)
    when 'PUT'
      @response = http.put(uri.path, data.to_json, @headers)
  end

  @last_request_url = uri.path
  @http_params = Hash.new
end

Then /^show me the (unparsed)?\s?response$/ do |unparsed|
  if unparsed == 'unparsed'
    puts @response.body
  elsif @response.header['Content-Type'] =~ /json/
    json_response = JSON.parse(@response.body)
    puts JSON.pretty_generate(json_response)
  elsif @response.header['Content-Type'] =~ /xml/
    puts Nokogiri::XML(@response.body)
  else
    puts @response.header
    puts @response.body
  end
end

Then /^the response status should be "([^"]*)"$/ do |status|
  if self.respond_to? :should
    @response.code.should == status
  else
    assert_equal status, @response.code
  end
end

Then /^the JSON response should (not)?\s?have "([^"]*)"$/ do |negative, json_path|
  json    = JSON.parse(@response.body)
  results = JsonPath.new(json_path).on(json).to_a.map(&:to_s)
  if self.respond_to?(:should)
    if negative
      results.should be_empty
    else
      results.should_not be_empty
    end
  else
    if negative
      assert results.empty?
    else
      assert !results.empty?
    end
  end
end


Then /^the JSON response should (not)?\s?have "([^"]*)" with the text "([^"]*)"$/ do |negative, json_path, text|
  json    = JSON.parse(@response.body)
  results = JsonPath.new(json_path).on(json).to_a.map(&:to_s)
  if self.respond_to?(:should)
    if negative
      results.should_not include(text)
    else
      results.should include(text)
    end
  else
    if negative
      assert !results.include?(text)
    else
      assert results.include?(text)
    end
  end
end

Then /^the XML response should (not)?\s?have "([^"]*)"$/ do |negative, xpath|
  parsed_response = Nokogiri::XML(@response.body)
  elements = parsed_response.xpath(xpath)
  if self.respond_to?(:should)
    if negative
      elements.should be_empty
    else
      elements.should_not be_empty
    end
  else
    if negative
      assert elements.empty?
    else
      assert !elements.empty?
    end
  end
end

Then /^the XML response should have "([^"]*)" with the text "([^"]*)"$/ do |xpath, text|
  parsed_response = Nokogiri::XML(@response.body)
  elements = parsed_response.xpath(xpath)
  if self.respond_to?(:should)
    elements.should_not be_empty, "could not find #{xpath} in:\n#{@response.body}"
    elements.find { |e| e.text == text }.should_not be_nil, "found elements but could not find #{text} in:\n#{elements.inspect}"
  else
    assert !elements.empty?, "could not find #{xpath} in:\n#{@response.body}"
    assert elements.find { |e| e.text == text }, "found elements but could not find #{text} in:\n#{elements.inspect}"
  end
end

Then /^the JSON response should be:$/ do |json|
  expected = JSON.parse(json)
  actual = JSON.parse(@response.body)

  if self.respond_to?(:should)
    actual.should == expected
  else
    assert_equal actual, @response.body
  end
end

Then /^the JSON response should have "([^"]*)" with a length of (\d+)$/ do |json_path, length|
  json = JSON.parse(@response.body)
  results = JsonPath.new(json_path).on(json)
  if self.respond_to?(:should)
    results.length.should == length.to_i
  else
    assert_equal length.to_i, results.length
  end
end
