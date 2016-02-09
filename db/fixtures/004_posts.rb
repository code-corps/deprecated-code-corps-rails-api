5.times do
  Post.seed do |post|
    post.title = "A task"
    post.body = "This is a basic task"
    post.body_preview = "This is a basic task"
    post.markdown = "This is a basic task"
    post.markdown_preview = "This is a basic task"
    post.project_id = 1
    post.user_id = 2
    post.post_type = "task"
    post.aasm_state = "published"
  end

  Post.seed do |post|
    post.title = "An idea"
    post.body = "This is a basic idea"
    post.body_preview = "This is a basic idea"
    post.markdown = "This is a basic idea"
    post.markdown_preview = "This is a basic idea"
    post.project_id = 1
    post.user_id = 2
    post.post_type = "idea"
    post.aasm_state = "published"
  end

  Post.seed do |post|
    post.title = "A progress post"
    post.body = "This is a basic progress post"
    post.body_preview = "This is a basic progress post"
    post.markdown = "This is a basic progress post"
    post.markdown_preview = "This is a basic progress post"
    post.project_id = 1
    post.user_id = 2
    post.post_type = "progress"
    post.aasm_state = "published"
  end

  Post.seed do |post|
    post.title = "An issue"
    post.body = "This is a basic issue"
    post.body_preview = "This is a basic issue"
    post.markdown = "This is a basic progress post"
    post.markdown_preview = "This is a basic progress post"
    post.project_id = 1
    post.user_id = 2
    post.post_type = "issue"
    post.aasm_state = "published"
  end
end
