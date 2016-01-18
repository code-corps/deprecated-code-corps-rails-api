User.seed do |user|
  user.id        = 1
  user.username  = "administrator"
  user.email     = "admin@example.org"
  user.password  = "password"
  user.admin     = true
end
