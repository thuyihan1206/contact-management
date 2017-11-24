class ApplicationController < ActionController::API
  rescue_from Mongoid::Errors::DocumentNotFound, with: :record_not_found

  protected

  def record_not_found(_exception)
    payload = {
      errors: { full_messages: ["cannot find id[#{params[:id]}]"] }
    }
    render json: payload, status: :not_found
  end

end
