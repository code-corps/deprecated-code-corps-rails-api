skills = [
  {
    title: "Ember.js",
  },
  {
    title: "HTML",
  },
  {
    title: "CSS",
  },
  {
    title: "Ruby",
  },
  {
    title: "Ruby on Rails",
  },
  {
    title: "Docker",
  },
]

skills.each do |skill|
  Skill.seed_once(:title) do |s|
    s.title = skill[:title]
    s.slug = skill[:title].parameterize
  end
end
