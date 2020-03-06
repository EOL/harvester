class FormatsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  def show
    @format = Format.find(params[:id])
  end

  def new
    resource = Resource.find(params[:resource_id])
    @format = Format.new(resource: resource, utf8: true, data_begins_on_line: 2)
    log_auth(@format)
  end

  def edit
    return render html: "Please stop."
    # @format = Format.find(params[:id])
    # log_auth(@format)
  end

  def create
    @format = Format.new(format_params)
    log_auth(@format)
    @format.field_sep.gsub!(/\\t/, "\t") # TODO: others? Maybe we should just use a picklist. :|
    if @format.save
      path = resource_format_path(@format, resource_id: @format.resource_id)
      flash[:notice] = I18n.t('formats.flash.created', name: @format.represents, path: path).html_safe
      redirect_to [@format.resource, @format]
    else
      # TODO: some kind of hint as to the problem, in a flash...
      render 'new'
    end
  end

  def update
    @format = Format.find(params[:id])
    log_auth(@format)
    # TODO: others? Maybe we should just use a picklist. :| ALSO GENERALIZE WITH EDIT
    format_params[:field_sep].gsub!(/\\t/, "\t")
    if @format.update(format_params)
      path = resource_format_path(@format, resource_id: @format.resource_id)
      flash[:notice] = I18n.t('formats.flash.edited', name: @format.represents, path: path).html_safe
      redirect_to [@format.resource, @format]
    else
      # TODO: some kind of hint as to the problem, in a flash...
      render 'new'
    end
  end

  def format_params
    params.require(:format).permit(
      :resource_id, :represents, :header_lines, :data_begins_on_line, :file_type, :field_sep, :sheet, :utf8, :get_from
    )
  end

  def destroy
    @format = Format.find(params[:id])
    log_auth(@format)
    name = @format.represents
    resource = @format.resource
    @format.destroy
    redirect_to resource, notice: I18n.t('formats.flash.destroyed', name: name)
  end
end
