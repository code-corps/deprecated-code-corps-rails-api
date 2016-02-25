Organization.seed do |organization|
  organization.id   = 1
  organization.name = "Code Corps"
  organization.slug = "code_corps"
end

OrganizationMembership.seed do |membership|
  membership.id = 1
  membership.member_id = 2
  membership.organization_id = 1
end
