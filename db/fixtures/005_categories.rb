categories = [
  {
    name: "Economy",
    description: "You want to improve finance and the economic climate."
  },
  {
    name: "Education",
    description: "You want to improve literacy, schools, and training."
  },
  {
    name: "Environment",
    description: "You want to improve your environment."
  },
  {
    name: "Government",
    description: "You want to improve government responsiveness."
  },
  {
    name: "Health",
    description: "You want to improve prevention and treatment."
  },
  {
    name: "Justice",
    description: "You want to improve your judicial system."
  },
  {
    name: "Politics",
    description: "You want to improve elections and voting."
  },
  {
    name: "Public Safety",
    description: "You want to improve crime prevention and safety."
  },
  {
    name: "Science",
    description: "You want to improve tools for advancing science."
  },
  {
    name: "Security",
    description: "You want to improve tools like encryption."
  },
  {
    name: "Society",
    description: "You want to improve our communities."
  },
  {
    name: "Technology",
    description: "You want to improve software tools and infrastructure."
  },
  {
    name: "Transportation",
    description: "You want to improve how people travel."
  },
]

categories.each do |category|
  Category.seed_once(:name) do |s|
    s.name = category[:name]
    s.slug = category[:name].parameterize
    s.description = category[:description]
  end
end
