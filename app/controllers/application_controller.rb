class ApplicationController < ActionController::API
  rescue_from Mongoid::Errors::DocumentNotFound, with: :record_not_found
  rescue_from Mongoid::Errors::Validations, with: :mongoid_validation_error

  protected

  def record_not_found(_exception)
    payload = {
      errors: { full_messages: ["cannot find id[#{params[:id]}]"] }
    }
    render json: payload, status: :not_found
  end

  def mongoid_validation_error(exception)
    payload = { errors: exception.record.errors.messages }
    render json: payload, status: :unprocessable_entity
  end

end
