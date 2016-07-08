User.seed do |user|
  user.id        = 1
  user.username  = "administrator"
  user.email     = "admin@example.org"
  user.password  = "password"
  user.admin     = true
end

User.seed do |user|
  user.id       = 2
  user.username = "testuser"
  user.email    = "test@example.com"
  user.password = "test"
  user.admin    = false
end
