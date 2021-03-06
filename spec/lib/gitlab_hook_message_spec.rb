require 'rails_helper'

describe GitlabHookMessage do

  let :push_data do
    <<-MSG
    {
      "before": "95790bf891e76fee5e1747ab589903a6a1f80f22",
      "after": "da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
      "ref": "refs/heads/master",
      "user_id": 4,
      "user_name": "John Smith",
      "project_id": 15,
      "repository": {
        "name": "Diaspora",
        "url": "git@example.com:mike/diasporadiaspora.git",
        "description": "",
        "homepage": "http://example.com/mike/diaspora",
        "git_http_url":"http://example.com/mike/diaspora.git",
        "git_ssh_url":"git@example.com:mike/diaspora.git",
        "visibility_level":0
      },
      "commits": [
        {
          "id": "b6568db1bc1dcd7f8b4d5a946b0b91f9dacd7327",
          "message": "Update Catalan translation to e38cb41.",
          "timestamp": "2011-12-12T14:27:31+02:00",
          "url": "http://example.com/mike/diaspora/commit/b6568db1bc1dcd7f8b4d5a946b0b91f9dacd7327",
          "author": {
            "name": "Jordi Mallach",
            "email": "jordi@softcatala.org"
          }
        },
        {
          "id": "da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
          "message": "fixed readme",
          "timestamp": "2012-01-03T23:36:29+02:00",
          "url": "http://example.com/mike/diaspora/commit/da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
          "author": {
            "name": "GitLab dev user",
            "email": "gitlabdev@dv6700.(none)"
          }
        }
      ],
      "total_commits_count": 4
    }
    MSG
  end

  let :tag_data do
    <<-MSG
    {
      "ref": "refs/tags/v1.0.0",
      "before": "0000000000000000000000000000000000000000",
      "after": "82b3d5ae55f7080f1e6022629cdb57bfae7cccc7",
      "user_id": 1,
      "user_name": "John Smith",
      "project_id": 1,
      "repository": {
        "name": "jsmith",
        "url": "ssh://git@example.com/jsmith/example.git",
        "description": "",
        "homepage": "http://example.com/jsmith/example",
        "git_http_url":"http://example.com/jsmith/example.git",
        "git_ssh_url":"git@example.com:jsmith/example.git",
        "visibility_level":0
      },
      "commits": [],
      "total_commits_count": 0
    }
    MSG
  end

  let :issue_data do
    <<-MSG
    {
      "object_kind": "issue",
      "user": {
        "name": "Administrator",
        "username": "root",
        "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon"
      },
      "object_attributes": {
        "id": 301,
        "title": "New API: create/update/delete file",
        "assignee_id": 51,
        "author_id": 51,
        "project_id": 14,
        "created_at": "2013-12-03T17:15:43Z",
        "updated_at": "2013-12-03T17:15:43Z",
        "position": 0,
        "branch_name": null,
        "description": "Create new API for manipulations with repository",
        "milestone_id": null,
        "state": "opened",
        "iid": 23,
        "url": "http://example.com/diaspora/issues/23",
        "action": "open"
      }
    }
    MSG
  end

  let :merge_request_data do
    <<-MSG
    {
      "object_kind": "merge_request",
      "user": {
        "name": "Administrator",
        "username": "root",
        "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=40\u0026d=identicon"
      },
      "object_attributes": {
        "id": 99,
        "target_branch": "master",
        "source_branch": "ms-viewport",
        "source_project_id": 14,
        "author_id": 51,
        "assignee_id": 6,
        "title": "MS-Viewport",
        "created_at": "2013-12-03T17:23:34Z",
        "updated_at": "2013-12-03T17:23:34Z",
        "st_commits": null,
        "st_diffs": null,
        "milestone_id": null,
        "state": "opened",
        "merge_status": "unchecked",
        "target_project_id": 14,
        "iid": 1,
        "description": "",
        "source": {
          "name": "awesome_project",
          "ssh_url": "ssh://git@example.com/awesome_space/awesome_project.git",
          "http_url": "http://example.com/awesome_space/awesome_project.git",
          "visibility_level": 20,
          "namespace": "awesome_space"
        },
        "target": {
          "name": "awesome_project",
          "ssh_url": "ssh://git@example.com/awesome_space/awesome_project.git",
          "http_url": "http://example.com/awesome_space/awesome_project.git",
          "visibility_level": 20,
          "namespace": "awesome_space"
        },
        "last_commit": {
          "id": "da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
          "message": "fixed readme",
          "timestamp": "2012-01-03T23:36:29+02:00",
          "url": "http://example.com/awesome_space/awesome_project/commits/da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
          "author": {
            "name": "GitLab dev user",
            "email": "gitlabdev@dv6700.(none)"
          }
        },
        "url": "http://example.com/diaspora/merge_requests/1",
        "action": "open"
      }
    }
    MSG
  end

  def json_to_msg(json)
    GitlabHookMessage.new JSON.parse(json).deep_symbolize_keys, nil
  end

  let(:push_msg) { json_to_msg(push_data) }
  let(:tag_msg) { json_to_msg(tag_data) }
  let(:issue_msg) { json_to_msg(issue_data) }
  let(:merge_request_msg) { json_to_msg(merge_request_data) }

  it 'message type' do
    expect(push_msg.type).to eq 'push'
    expect(tag_msg.type).to eq 'tag'
    expect(issue_msg.type).to eq 'issue'
    expect(merge_request_msg.type).to eq 'merge_request'
  end
end