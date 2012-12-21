class RegistrationsController < Devise::RegistrationsController

  def new
    @plan = params[:plan]
    if @plan
      @signature = Recurly.js.sign :subscription => { :plan_code => @plan }
      super
    else
      redirect_to root_path, :notice => 'Please select a subscription plan below'
    end
  end

  private
  def build_resource(*args)
    super
    if params[:plan]
      resource.add_role(params[:plan])
    end
    resource.customer_id ||= SecureRandom.uuid
  end
end