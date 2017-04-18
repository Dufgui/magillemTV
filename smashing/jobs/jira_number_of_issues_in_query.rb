require 'jira-ruby'

JIRA_PROPS = {
  'url' => URI.parse(ENV['JIRA_URL'] || "http://localhost:8080"),
  'username' => ENV['JIRA_USERNAME'] || "username",
  'password' => ENV['JIRA_PASSWORD'] || "password",
  'proxy_address' => nil,
  'proxy_port' => nil
}

# the key of this mapping must be a unique identifier for your jql filter, the according value must be the jql filter id or filter name that is used in Jira
query_mapping = {
  'query1' => { :query => 'project = "MyProject"' },
}

jira_options = {
  :username => JIRA_PROPS['username'],
  :password => JIRA_PROPS['password'],
  :context_path => JIRA_PROPS['url'].path,
  :site => JIRA_PROPS['url'].scheme + "://" + JIRA_PROPS['url'].host,
  :auth_type => :basic,
  :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
  :use_ssl => JIRA_PROPS['url'].scheme == 'https' ? true : false,
  :proxy_address => JIRA_PROPS['proxy_address'],
  :proxy_port => JIRA_PROPS['proxy_port']
}

last_issues = Hash.new(0)

query_mapping.each do |query_data_id, query|
  SCHEDULER.every '10s', :first_in => 0 do |job|
    last_number_issues = last_issues['query_data_id']
    client = JIRA::Client.new(jira_options)
    current_number_issues = client.Issue.jql(query[:query]).size
    last_issues['query_data_id'] = current_number_issues
    send_event(query_data_id, { current: current_number_issues, last: last_number_issues})
  end
end