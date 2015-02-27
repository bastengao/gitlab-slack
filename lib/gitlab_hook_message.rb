class GitlabHookMessage
  attr_reader :data

  def initialize(data)
    @data = data
  end

  # issue, merge_request, tag, push
  def type
    @data['object_kind'] || ( @data['total_commits_count'] == 0 ? 'tag' : 'push' )
  end

  def [](key)
    @data[key]
  end
end