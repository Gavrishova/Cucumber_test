require 'capybara'
require 'minitest/autorun'

module MinitestAssertionsBridge
  attr_accessor :assertions
end

World MinitestAssertionsBridge
MultiTest.disable_autorun

Capybara.default_driver = :selenium
Capybara.default_wait_time = 10
Capybara.default_selector = :css

Before do
  self.assertions = 0
end


After do |scenario|
  if scenario.failed? do
    screenshot = "./report/Fail/FAILED_#{scenario.name.gsub(' ', '_').gsub(/[^0-9A-Za-z_]/, '')}.png"
    page.driver.save_screenshot(screenshot)
    encoded_img = page.driver.browser.screenshot_as(:base64)
    embed("data:image/png;base64,#{encoded_img}", 'image/png')
  end
#branch for Pass scenario
  #else
    #screenshot = "./report/Pass/PASSED_#{scenario.name.gsub(' ', '_').gsub(/[^0-9A-Za-z_]/, '')}.png"
    #page.driver.save_screenshot(screenshot)
    #encoded_img = page.driver.browser.screenshot_as(:base64)
    #embed("data:image/png;base64,#{encoded_img}", 'image/png')
  end

#Capybara.reset_sessions!
end
  Around('@api') do |scenario, block|
    $test_result = Hash.new
    block.call
    puts $test_result.to_s
  end