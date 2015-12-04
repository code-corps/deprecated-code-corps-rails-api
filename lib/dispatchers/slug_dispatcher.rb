class SlugDispatcher
  def initialize(router)
    @router = router
  end

  def call(env)
    slug = env["action_dispatch.request.path_parameters"][:slug]
    record = SlugRoute.find_by_slug(slug)
    if record
      Render.new(record).call(@router, env)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  class Render
    def initialize(model)
      @model = model
    end

    def call(router, env)
      controller = "#{@model.owner.class.to_s.pluralize}Controller".constantize
      env["action_dispatch.request.path_parameters"][:id] = @model.owner_id
      env["action_dispatch.request.path_parameters"][:action] = "show"
      controller.action("show").call(env)
    end
  end
end
