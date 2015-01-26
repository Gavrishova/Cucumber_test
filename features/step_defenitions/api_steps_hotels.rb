require 'rspec'
require 'test/unit/assertions'

include Test::Unit::Assertions

And /^I remember id of city$/ do
  json_response = JSON.parse(@response.body)
  @city_id = Array.new
  for i in 1..json_response['result'].length - 1

    @city_id.push(json_response['result'][i]['city_id'].to_s)

  end

end


And /^I use the saved id of city and random date$/ do
  @random_city_id = @city_id.sample
  @date_checkIn = Faker::Date.between(Date.today + 14, Date.today + 21)
  @date_checkOut = Faker::Date.between(@date_checkIn + 1, @date_checkIn + 9)

  step 'I add http parameters:', '{"city_id": "' + @random_city_id + '", "date_start": "' + @date_checkIn.strftime("%Y-%m-%d") +
      '", "date_end": "' + @date_checkOut.strftime("%Y-%m-%d") + '"}'
end


And /^I save the request id$/ do
  json_response = JSON.parse(@response.body)
  @request_id = json_response['result']['request_id'].to_s
end


And /^Add request id to request$/ do
  sleep rand(1..2)
  step 'I add http parameters:', '{"request_id": "' + @request_id + '"}'
end


And /^I check the status of response$/ do
  json_response = JSON.parse(@response.body)
  @status = json_response['result']['status'].to_s

  until @status == 'done'

    step 'I add http parameters:', '{"request_id": "' + @request_id + '"}'
    step 'I send a GET request to "/searchPolling" with the following:
       | lang | ru |'
    json_response = JSON.parse(@response.body)
    @status = json_response['result']['status'].to_s

  end

end


And /^I save the id of hotels$/ do
  json_response = JSON.parse(@response.body)
  @id_hotels = Array.new
  for i in 1..json_response['result']['offers'].length - 1

    @id_hotels.push(json_response['result']['offers'][i][0].to_s)

  end

end


And /^I use the saved id of hotel and random date$/ do
  @random_hotel_id = @id_hotels.sample
  step 'I add http parameters:', '{"hotel_id": "' + @random_hotel_id + '", "date_start": "' + @date_checkIn.strftime("%Y-%m-%d") +
      '", "date_end": "' + @date_checkOut.strftime("%Y-%m-%d") + '"}'
end

And /^I check the provider$/ do
  json_response = JSON.parse(@response.body)
  @info_provider = json_response['result']['rooms']['lowest_price_by_gate']
  @provider = @info_provider.map { |h| h["provider"] }
  @check_ott = @provider.include? 'ott'
  @check_ean = @provider.include? 'ean'

  unless @check_ott == true or @check_ean == true
    @random_hotel_id = @id_hotels.sample
    step 'I add http parameters:', '{"hotel_id": "' + @random_hotel_id + '", "date_start": "' + @date_checkIn.strftime("%Y-%m-%d") +
        '", "date_end": "' + @date_checkOut.strftime("%Y-%m-%d") + '"}'
    step 'I send a GET request to "/offersRequest" with the following:
       | lang | ru |
       | currency | USD |'
    json_response = JSON.parse(@response.body)
    @info_provider = json_response['result']['rooms']['lowest_price_by_gate']
    @provider = @info_provider.map { |h| h["provider"] }
    @check_ott = @provider.include? 'ott'
    @check_ean = @provider.include? 'ean'

  end
  @token = @info_provider.find { |i| i["provider"] == "ott" or i["provider"] == "ean" }["token"]

end

And /^I expect response time to be 2 sec/ do
  @last_request_expected_response_time = 2000
end


And /^I remember response time/ do
  json_response = JSON.parse(@response.body)
  $test_result[@last_request_url] = Hash.new
  $test_result[@last_request_url]["responseTime"] = json_response["_info"]["response"]
  $test_result[@last_request_url]["expectedResposneTime"] = @last_request_expected_response_time
  $test_result[@last_request_url]["responseTimeDiff"] = @last_request_expected_response_time - json_response["_info"]["response"].to_f
  $test_result[@last_request_url]["worker"] = @response['x-worker']
end


And /^I save the token of provider$/ do
  @token = @info_provider.find { |i| i["provider"] == "ott" or i["provider"] == "ean" }["token"]
end

And /^I use the saved token of provider$/ do
  step 'I add http parameters:', '{"token": "' + @token + '"}'
end

Then /^I should see correct offer$/ do
  json_response = JSON.parse(@response.body)
  check_date_start = json_response['result']['params']['date_start'].to_s
  actual_date_start = @date_checkIn.strftime("%Y-%m-%d")
  assert_equal(check_date_start, actual_date_start, 'The start date is not equal')
  check_date_end = json_response['result']['params']['date_end'].to_s
  actual_date_end = @date_checkOut.strftime("%Y-%m-%d")
  assert_equal(check_date_end, actual_date_end, 'The end date is not equal')
  hotels = json_response['result']['hotel']['id'].to_i
  assert_equal(@random_hotel_id.to_i, hotels, 'The hotel id is not equal')
end

