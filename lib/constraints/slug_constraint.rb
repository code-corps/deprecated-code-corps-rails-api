class SlugConstraint
  def initialize klass
    @type = klass.to_s
  end

  def matches? request
    params = request.path_parameters
    slug = params[:slug]
    record = SlugRoute.find_by_slug(slug)
    if record && record.owner_type == @type
      request.path_parameters[:id] = record.owner_id
      return true
    end
  end
end
