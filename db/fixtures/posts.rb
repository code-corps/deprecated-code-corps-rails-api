5.times do |index|
  Post.seed do |post|
    post.id = index
    post.title = "A task"
    post.body = "This is a basic task"
    post.markdown = "This is a basic task"
    post.project_id = 1
    post.user_id = 2
    post.post_type = "task"
  end
end

5.times do |index|
  Post.seed do |post|
    post.id = index + 5
    post.title = "An idea"
    post.body = "This is a basic idea"
    post.markdown = "This is a basic idea"
    post.project_id = 1
    post.user_id = 2
    post.post_type = "idea"
  end
end

5.times do |index|
  Post.seed do |post|
    post.id = index + 10
    post.title = "A progress post"
    post.body = "This is a basic progress post"
    post.markdown = "This is a basic progress post"
    post.project_id = 1
    post.user_id = 2
    post.post_type = "progress"
  end
end

5.times do |index|
  Post.seed do |post|
    post.id = index + 15
    post.title = "An issue"
    post.body = "This is a basic issue"
    post.markdown = "This is a basic issue"
    post.project_id = 1
    post.user_id = 2
    post.post_type = "issue"
  end
end
