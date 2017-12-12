module RenderHelper
  extend ActiveSupport::Concern

  def render_failure_json(status: nil, errors: [], message: "Failure.")
    render_params = {
      json: {
        errors: errors,
        meta: { success: false, message: message }
      },
      status: status
    }

    render render_params.compact
  end

  def render_service(outcome: nil, serializer: nil, data: nil)
    if outcome.valid?
      render_service_success_json(outcome, serializer: serializer, data: data)
    else
      render_service_failure_json(outcome)
    end
  end

  def render_service_failure_json(outcome)
    render_failure_json(
      errors: outcome.errors,
      message: outcome.failure_message,
      status: outcome.failure_status || 422
    )
  end

  def render_service_success_json(outcome, serializer: nil, data: nil)
    # TODO: Figure out why outcome.success_message does not exist
    binding.pry
    data ||= outcome.result
    message = outcome.success_message
    render_success_json(data: data, message: message, serializer: serializer)
    # render_success_json(
    #   data: outcome.result,
    #   message: outcome.success_message,
    #   serializer: serializer
    # )
  end

  def render_success_json(data: {}, message: "Success!", serializer: nil)
    render_params = {
      include: "**",
      json: data,
      meta: { success: true, message: message },
      serializer_key(data) => serializer,
      status: 200
    }

    render render_params.compact
  end

  private

  def serializer_key(data)
    data.is_a?(ActiveRecord::Base) ? :serializer : :each_serializer
  end
end
