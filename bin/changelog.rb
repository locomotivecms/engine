#!/usr/bin/env ruby
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'thor'
require 'github_api'

class ChangelogCommand < Thor

  desc 'milestone TITLE', 'Generate the changelog of a milestone in Markdown'
  method_option :file, aliases: '-f', type: :boolean, default: false, desc: 'Write the output in the doc/changelogs/<milestone>.md file.'
  method_option :force, type: :boolean, default: false, desc: 'Overwrite the file.'
  def milestone(title)
    _milestone  = self.get_milestone(title)
    report      = self.get_issues_report(_milestone)

    if options[:file]
      path = File.dirname(File.expand_path(__FILE__))
      path = File.join(path, '..', 'doc/changelogs', "#{_milestone.title}.md")

      if !File.exists?(path) || options[:force]
        File.open(path, 'w+') { |f| f.write(report) }
      end
    else
      puts report
    end
  end

  protected

  def get_issues_report(milestone)
    github    = Github.new
    list      = github.issues.send(:list_repo, 'locomotivecms', 'engine', milestone: milestone.number , state: 'closed')
    people    = []

    "## Changelog for the #{milestone.title} milestone\n".tap do |report|

      # major features
      report << "### Major features\n"

      # issues
      report << "### List of all closed features/issues\n"

      list.each_page do |page|
        page.each do |issue|
          labels = issue.labels.map(&:name).keep_if { |n| !['awaiting fix', 'awaiting feedback'].include?(n) }.join(', ')
          labels = "(#{labels})" if labels != ''
          report << %(* **[#{issue.title}](#{issue.html_url})** #{labels}\n)

          people << issue.user.login if issue.user
          people << issue.assignee.login if issue.assignee
        end
      end

      # assignees
      report << "\n\n### People who participated:\n"
      report << "Please let us know if we forgot somebody.\n"
      report << people.uniq.compact.map { |login| "* [#{login}](https://github.com/#{login})" }.join("\n")
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