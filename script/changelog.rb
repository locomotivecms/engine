#!/usr/bin/env ruby
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'thor'
require 'github_api'

class ChangelogCommand < Thor

  desc 'milestone TITLE', 'Generate the changelog of a milestone'
  def milestone(title)
    _milestone = self.get_milestone(title)
    puts "milestone = #{_milestone.number} (#{_milestone.state})"
    puts "----"
    self.get_issues(_milestone)
  end

  protected

  def get_issues(milestone)
    issues = Github::Issues.new(user: 'locomotivecms', repo: 'engine').all(state: 'closed', milestone: milestone.number)
    issues.list.each do |issue|
      puts issue.title
    end
  end

  def get_milestone(title)
    issues = Github::Issues.new(user: 'locomotivecms', repo: 'engine')
    %w(closed open).each do |state|
      issues.milestones.list(state: state).each do |milestone|
        return milestone if milestone.title == title
      end
    end
    raise "Unknown milestone '#{title}'"
  end

end

ChangelogCommand.start


# require 'httparty'
# require 'thor'

# $base_url = 'https://api.github.com/repos/locomotivecms/engine/'

# class ChangelogCommand < Thor

#   desc 'milestone TITLE', 'Generate the changelog of a milestone'
#   def milestone(title)
#     number = self.get_milestone_number(title)
#     puts "number = #{number}"
#   end

#   protected

#   def get_milestone_issues(number)

#   end

#   def get_milestone_number(title)
#     %w(closed open).each do |state|
#       self.send_api_request('milestones', "state=#{state}").each do |changelog|
#         return changelog['number'] if changelog['title'] == title
#       end
#     end
#     raise "Unknown milestone '#{title}'"
#   end

#   def send_api_request(path, query)
#     url = URI.join($base_url, path, query ? "?#{query}" : '').to_s
#     HTTParty.get(url, headers: { 'User-Agent' => 'locomotivecms' })
#   end

# end

# ChangelogCommand.start
