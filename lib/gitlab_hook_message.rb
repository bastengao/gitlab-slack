# ref: https://github.com/gitlabhq/gitlabhq/blob/master/app/models/project_services/slack_message.rb
class GitlabHookMessage
  attr_reader :data

  attr_reader :after
  attr_reader :before
  attr_reader :commits
  attr_reader :project_name
  attr_reader :project_url
  attr_reader :ref
  attr_reader :username

  def initialize(data)
    @data = data

    if type.in? %w[push tag]
      params = @data
      @after = params.fetch(:after)
      @before = params.fetch(:before)
      @commits = params.fetch(:commits, [])
      @project_name = params.fetch(:project_name)
      @project_url = params.fetch(:project_url)
      @ref = params.fetch(:ref).gsub('refs/heads/', '')
      @username = params.fetch(:user_name)
    end
  end

  # issue, merge_request, tag, push
  def type
    @data[:object_kind] || (@data[:total_commits_count] == 0 ? 'tag' : 'push')
  end

  def [](key)
    @data[key]
  end

  def pretext
    format(message)
  end

  def attachments
    return [] if issue? || merge_request?
    return [] if new_branch? || removed_branch?

    commit_message_attachments
  end

  private

  def message
    if issue?
      return issue_message
    elsif merge_request?
      return merge_request
    end

    if new_branch?
      new_branch_message
    elsif removed_branch?
      removed_branch_message
    else
      push_message
    end
  end

  def format(string)
    Slack::Notifier::LinkFormatter.format(string)
  end

  def issue_message
    "#{@data[:user][:name]} #{@data[:object_attributes][:action]} issue #{issue_link}"
  end

  def merge_request
    "#{@data[:user][:name]} #{@data[:object_attributes][:action]} merge request #{merge_request_link}"
  end

  def new_branch_message
    "#{username} pushed new branch #{branch_link} to #{project_link}"
  end

  def removed_branch_message
    "#{username} removed branch #{ref} from #{project_link}"
  end

  def push_message
    "#{username} pushed to branch #{branch_link} of #{project_link} (#{compare_link})"
  end

  def commit_messages
    commits.each_with_object('') do |commit, str|
      str << compose_commit_message(commit)
    end.chomp
  end

  def commit_message_attachments
    [{ text: format(commit_messages), color: attachment_color }]
  end

  def compose_commit_message(commit)
    author = commit.fetch(:author).fetch(:name)
    id = commit.fetch(:id)[0..8]
    message = commit.fetch(:message)
    url = commit.fetch(:url)

    "[#{id}](#{url}): #{message} - #{author}\n"
  end

  def issue?
    type == 'issue'
  end

  def merge_request?
    type == 'merge_request'
  end

  def new_branch?
    before.include?('000000')
  end

  def removed_branch?
    after.include?('000000')
  end

  def branch_url
    "#{project_url}/commits/#{ref}"
  end

  def compare_url
    "#{project_url}/compare/#{before}...#{after}"
  end

  def issue_link
    "[#{@data[:object_attributes][:title]}](#{@data[:object_attributes][:url]})"
  end

  def merge_request_link
    "[#{@data[:object_attributes][:title]}](#{@data[:object_attributes][:url]})"
  end

  def branch_link
    "[#{ref}](#{branch_url})"
  end

  def project_link
    "[#{project_name}](#{project_url})"
  end

  def compare_link
    "[Compare changes](#{compare_url})"
  end

  def attachment_color
    '#345'
  end
end