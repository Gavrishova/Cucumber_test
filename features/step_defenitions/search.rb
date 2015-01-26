require 'capybara'
require 'selectors'
require 'faker'

include Capybara
include Selectors

Given /^I navigate to site$/ do
  visit('https://www.onetwotrip.com/uk-ua/hotels')
  page.driver.browser.manage.window.maximize
end


And /^I  type the city$/ do
  fill_in HOME[:type_field][:place], with: 'Moscow'
end


And /^Select date$/ do
  dateFrom = Faker::Date.between(Date.today + 15, Date.today + 20)
  dateTo = Faker::Date.between(dateFrom + 1, dateFrom + 10)
  find(HOME[:type_field][:dateFrom]).click
  current_month = Date.today

  if dateFrom.day > 31 or dateFrom.month != current_month.month
    find(HOME[:calendar_next]).click
  end

  find('.currentMonth.cls' + dateFrom.strftime("%Y%m%d")).click
  find(HOME[:type_field][:dateTo]).click
  find('.currentMonth.cls' + dateTo.strftime("%Y%m%d") + '.enabled').click
end


And(/^Press search button$/) do
  find(HOME[:buttons][:search]).click
end


And /^Sort the page by price$/ do
  page.driver.browser.switch_to.window page.driver.browser.window_handles.last do
    page.driver.browser.manage.window.maximize
    find(HOME[:sorting][:cheapest]).click
    page.has_no_css?(HOME[:loading])
  end

end


Then /^I have the cheapest hotel with image available on the page$/ do
  page.driver.browser.switch_to.window page.driver.browser.window_handles.last do
    hotels = Capybara::Node::Finders.all(HOME[:link_hotel])

    image_found_on_page = false
    hotels.each do |hotel|
      if (image_found_on_page)
        break
      end

      hotel.click

      page.driver.browser.switch_to.window page.driver.browser.window_handles.last do
        page.driver.browser.manage.window.maximize
        image_found_on_page = page.has_css?(HOME[:main_photo])
      end
    end

    expect(image_found_on_page).to be true
  end
end


