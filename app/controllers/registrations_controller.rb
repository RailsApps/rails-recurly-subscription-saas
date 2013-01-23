class RegistrationsController < Devise::RegistrationsController

  def new
    @plan = params[:plan]
    if @plan && ENV["ROLES"].include?(@plan) && @plan != "admin"
      @signature = Recurly.js.sign :subscription => { :plan_code => @plan }
      super
    else
      redirect_to root_path, :notice => 'Please select a subscription plan below'
    end
  end

  def update_plan
    @user = current_user
    role = Role.find(params[:user][:role_ids]) unless params[:user][:role_ids].nil?
    if @user.update_plan(role)
      redirect_to edit_user_registration_path, :notice => 'Updated plan.'
    else
      flash.alert = 'Unable to update plan.'
      render :edit
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
