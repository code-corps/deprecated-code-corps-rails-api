roles = [
  {
    name: "Backend Developer",
    ability: "Backend Development",
    kind: "technology",
  },
  {
    name: "Data Scientist",
    ability: "Data Science",
    kind: "technology",
  },
  {
    name: "DevOps",
    ability: "DevOps",
    kind: "technology",
  },
  {
    name: "Front End Developer",
    ability: "Front End Development",
    kind: "technology",
  },
  {
    name: "Mobile Developer",
    ability: "Mobile Development",
    kind: "technology",
  },
  {
    name: "Product Manager",
    ability: "Product Management",
    kind: "technology",
  },
  {
    name: "Tester",
    ability: "Testing",
    kind: "technology",
  },
  {
    name: "Designer",
    ability: "Design",
    kind: "creative",
  },
  {
    name: "Marketer",
    ability: "Marketing",
    kind: "creative",
  },
  {
    name: "Photographer",
    ability: "Photography",
    kind: "creative",
  },
  {
    name: "Video Producer",
    ability: "Video Production",
    kind: "creative",
  },
  {
    name: "Writer",
    ability: "Writing",
    kind: "creative",
  },
  {
    name: "Accountant",
    ability: "Accounting",
    kind: "support",
  },
  {
    name: "Administrator",
    ability: "Administrative",
    kind: "support",
  },
  {
    name: "Donor",
    ability: "Donations",
    kind: "support",
  },
  {
    name: "Lawyer",
    ability: "Legal",
    kind: "support",
  },
  {
    name: "Researcher",
    ability: "Research",
    kind: "support",
  },
]

roles.each do |role|
  Role.seed_once(:name) do |s|
    s.name = role[:name]
    s.ability = role[:ability]
    s.kind = role[:kind]
  end
end
