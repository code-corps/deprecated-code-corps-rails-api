User.seed do |user|
  user.id        = 1
  user.username  = "admin"
  user.email     = "admin@example.org"
  user.password  = "password"
  user.admin     = true
end