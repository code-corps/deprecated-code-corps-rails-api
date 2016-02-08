User.seed do |user|
  user.id        = 1
  user.username  = "administrator"
  user.email     = "admin@example.org"
  user.password  = "password"
  user.admin     = true
end

User.seed do |user|
  user.id       = 2
  user.username = "codecorpsguy"
  user.email    = "guy@codecorps.com"
  user.password = "codecorps"
  user.admin    = false
end
