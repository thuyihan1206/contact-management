class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :update, :destroy]

  # GET /contacts
  # GET /contacts.json
  # accept optional request parameters
  def index
    @contacts = Contact.all

    [:first_name, :last_name, :email].each do |param|
      if params[param].present?
        regexp = /\A#{Regexp.escape(params[param].strip)}\Z/i # ignore case
        @contacts = @contacts.where(param => regexp)
      end
    end

    if params[:phone].present?
      standard_phone = Contact.standardize_phone_format(params[:phone]) # standardize phone number
      @contacts = @contacts.where(phone: standard_phone)
    end

    if @contacts.blank?
      payload = {
        success: { full_messages: ['no record found'] }
      }
      render json: payload, status: :ok
    else
      render json: @contacts if stale? last_modified: @contacts.max(:updated_at)
    end
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
    render json: @contact if stale? @contact
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      fresh_when(@contact)
      render json: @contact, status: :created, location: @contact
    else
      render json: { errors: @contact.errors.messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    if @contact.update(contact_params)
      fresh_when(@contact)
      render json: @contact, status: :ok, location: @contact
    else
      render json: { errors: @contact.errors.messages }, status: :unprocessable_entity
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    if @contact.destroy
      payload = {
        success: { full_messages: ["deleted id[#{params[:id]}]"] }
      }
      render json: payload, status: :ok
    else
      render json: { errors: @contact.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(:first_name, :last_name, :phone, :email)
  end
end
