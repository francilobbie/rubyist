# app/controllers/admin/users_controller.rb
class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :suspend, :unsuspend]

  def index

    @query = params[:query]

    if @query.present?
      @users = User.where("email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ? OR username ILIKE ? OR id::text ILIKE ?",
                          "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%", "%#{@query}%")
    else
      @users = User.all
    end

    # Basic users fetching, replace this with more complex logic if needed
    @users = User.all
    @admins = User.with_role(:admin) # Adjust as per your role management system
    @writers = User.with_role(:writer)
    @moderators = User.with_role(:moderator)
    @total_users = User.count
    @total_admins = User.joins(:roles).where(roles: { name: 'admin' }).count
    @total_writers = User.joins(:roles).where(roles: { name: 'writer' }).count
    @total_moderators = User.joins(:roles).where(roles: { name: 'moderator' }).count
    @total_suspended_users = User.where(suspended: true).or(User.where('suspended_until > ?', Time.current)).count

    @suspended_users = User.where(suspended: true).or(User.where('suspended_until > ?', Time.current))

    sort_users_by_param(params[:sort])
    sort_admins_by_param(params[:sort])
    sort_writers_by_param(params[:sort])
    sort_moderators_by_param(params[:sort])
    sort_suspended_users_by_param(params[:sort])

    respond_to do |format|
      format.html # for standard HTML responses
      format.turbo_stream do
        if params[:table_type] == 'admins'
          render turbo_stream: turbo_stream.replace("admins_table", partial: "admins_table", locals: { admins: @admins })
        elsif params[:table_type] == 'users'
          render turbo_stream: turbo_stream.replace("users_table", partial: "users_table", locals: { users: @users })
        elsif params[:table_type] == 'writers'
          render turbo_stream: turbo_stream.replace("writers_table", partial: "writers_table", locals: { writers: @writers })
        elsif params[:table_type] == 'moderators'
          render turbo_stream: turbo_stream.replace("moderators_table", partial: "moderators_table", locals: { moderators: @moderators })
        elsif params[:table_type] == 'suspended'
          render turbo_stream: turbo_stream.replace("suspended_table", partial: "suspended_table", locals: { suspended_users: @suspended_users })
        end
      end
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    @user.build_profile unless @user.profile
  end

  def update
    if current_user == @user || !current_user.has_role?(:admin)
      flash[:alert] = "You cannot change your own role or you do not have permission to change roles."
      redirect_to admin_user_path(@user) and return
    end
    # Separate role IDs update from other user attributes.
    update_roles_if_provided

    # Update other user attributes without role_ids to avoid unpermitted parameter warning.
    # In your update action, before the update(user_params) call
    _dummy = params[:user].delete(:role_ids) if params[:user][:role_ids]
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'User was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def new
    @user = User.new
    @user.build_profile
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_users_path, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  def search
    query = params[:q]

    @users = User.joins(:profile)
                 .where("users.email ILIKE :query OR profiles.first_name ILIKE :query OR profiles.last_name ILIKE :query OR users.id::text ILIKE :query",
                        query: "%#{query}%")
                 .select("users.id, users.email, profiles.first_name, profiles.last_name")

    render json: @users.as_json(only: [:id, :email], methods: [:first_name, :last_name])
  end


  def suspend
    # Set suspended_until for temporary suspension, set suspended for permanent
    if params[:duration].present?
      @user.update(suspended_until: Time.current + params[:duration].to_i.days)
    else
      @user.update(suspended: true)
    end

    # Increment suspension count
    @user.increment!(:suspension_count)
    redirect_to admin_users_path, notice: 'User has been suspended.'
  end

  def unsuspend
    # Remove suspension
    @user.update(suspended: false, suspended_until: nil)
    redirect_to admin_users_path, notice: 'User suspension has been lifted.'
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_users_url, notice: 'User has been deleted.'
  end

  private

  def ensure_admin!
    redirect_to root_path unless current_user.has_role?(:admin)
  end

  def user_params
    params.require(:user).permit(
      :email,
      :id,
      :password,
      :password_confirmation,
      role_ids: [],
      profile_attributes: %i[first_name last_name bio location]
    )
  end

  def update_roles_if_provided
    if params[:user][:role_ids]
      role_ids = params[:user][:role_ids].split(',').reject(&:empty?)
      @user.roles = Role.where(id: role_ids)
    elsif params[:user].key?(:role_ids)
      # Ensures roles are cleared only if role_ids key is present but empty.
      @user.roles.clear
    end
  end

  def sort_users_by_param(sort_key)
    case sort_key
    when 'user_date_asc'
      @users = @users.order(created_at: :asc)
    when 'user_date_desc'
      @users = @users.order(created_at: :desc)
    when 'user_email_asc'
      @users = @users.order(email: :asc)
    when 'user_email_desc'
      @users = @users.order(email: :desc)
    end
  end

  def sort_admins_by_param(sort_key)
    case sort_key
    when 'admin_date_asc'
      @admins = @admins.order(created_at: :asc)
    when 'admin_date_desc'
      @admins = @admins.order(created_at: :desc)
    when 'admin_email_asc'
      @admins = @admins.order(email: :asc)
    when 'admin_email_desc'
      @admins = @admins.order(email: :desc)
    end
  end

  def sort_writers_by_param(sort_key)
    case sort_key
    when 'writer_date_asc'
      @writers = @writers.order(created_at: :asc)
    when 'writer_date_desc'
      @writers = @writers.order(created_at: :desc)
    when 'writer_email_asc'
      @writers = @writers.order(email: :asc)
    when 'writer_email_desc'
      @writers = @writers.order(email: :desc)
    end
  end

  def sort_moderators_by_param(sort_key)
    case sort_key
    when 'moderator_date_asc'
      @moderators = @moderators.order(created_at: :asc)
    when 'moderator_date_desc'
      @moderators = @moderators.order(created_at: :desc)
    when 'moderator_email_asc'
      @moderators = @moderators.order(email: :asc)
    when 'moderator_email_desc'
      @moderators = @moderators.order(email: :desc)
    end
  end

  def sort_suspended_users_by_param(sort_key)
    Rails.logger.debug "Sorting suspended users by #{sort_key}"
    case sort_key
    when 'suspended_date_asc'
      @suspended_users = @suspended_users.order(created_at: :asc)
    when 'suspended_date_desc'
      @suspended_users = @suspended_users.order(created_at: :desc)
    when 'suspended_email_asc'
      @suspended_users = @suspended_users.order(email: :asc)
    when 'suspended_email_desc'
      @suspended_users = @suspended_users.order(email: :desc)
    end
  end


  def set_user
    @user = User.find(params[:id])
  end
end
