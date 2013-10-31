require 'conjur/api'

When(/^I( try)? to create a secret$/) do |try|
  @response = begin
    v = {
      mime_type: 'text/plain',
      kind: 'test-secret'
    }
    variable = JSON.parse(rest_resource(:directory)['variables'].post(v).body)
    e = {
      name: SecureRandom.uuid,
      variableid: variable['id']
    }
    rest_resource(:directory)[environment_path]['variables'].post(e)
  rescue RestClient::Exception
    handle_rest_exception try, $!
  end
end

When(/^I( try)? to use the secret$/) do |try|
  @response = begin
    variableid = JSON.parse(rest_resource(:directory)[environment_path].get.body)['variables']['db-password']
    raise "No db-password in environment" unless variableid
    rest_resource(:directory)['variables'][CGI.escape variableid].get
  rescue RestClient::Exception
    handle_rest_exception try, $!
  end
end

When(/^I check my permission to "(.*?)" the "(.*?)" resource named "(.*?)"$/) do |privilege, resource_kind, resource_id|
  @response = begin
    rest_resource(:authz)[Conjur::Config[:account]]['resources'][resource_kind][Conjur::Config[:namespace]][resource_id]["?check&privilege=#{privilege}"].get
  rescue RestClient::Exception
    handle_rest_exception true, $!
  end
end

Then /^it is (?:allowed|confirmed)$/ do
  [ 200, 201, 204 ].should be_member(@response.code)
end

Then /^I am not authenticated$/ do
  @response.code.should == 401
end

Then /^it is refused$/ do
  @response.code.should == 404
end

Then /^it is denied$/ do
  @response.code.should == 403
end

Given(/^I am logged in as "(.*?)"$/) do |user|
  login_as user
end

Then(/^the response should be "(.*?)"$/) do |response|
  @response.body.should == response
end