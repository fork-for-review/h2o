class QuestionInstancesController < BaseController
  cache_sweeper :question_instance_sweeper
  caches_action :updated, :cache_path => Proc.new {|c| "updated-at-#{c.params[:id]}"}
  caches_action :last_updated_question, :cache_path => Proc.new {|c| "last-updated-question-#{c.params[:id]}"}

  before_filter :prep_resources
  before_filter :load_question_instance, :only => [:destroy, :edit]

  after_filter :update_question_instance_time

  access_control do
    allow :owner, :of => :question_instance, :to => [:destroy, :edit]
    allow all, :to => [:index, :updated, :last_updated_question, :is_owner, :show, :new, :create, :update]
  end

  rescue_from Acl9::AccessDenied do |exception|
    redirect_to :action => :index
  end

  # GET /question_instances
  # GET /question_instances.xml
  def index
    add_stylesheets "tablesorter-blue-theme/style"
    add_javascripts "jquery.tablesorter.min"

    @question_instances = QuestionInstance.find(:all, :order => :id)

    respond_to do |format|
      format.html { render :layout => (! request.xhr?) }
      format.xml  { render :xml => @question_instances }
    end
  end

  def updated
    question_instance = QuestionInstance.find(params[:id])
    render :text => question_instance.updated_at.to_s
  rescue Exception => e
    render :text => 'Unable to update right now. Please try again in a few minutes by refreshing your browser', :status => :service_unavailable
  end

  def last_updated_question
    question_instance = QuestionInstance.find(params[:id])
    render :text => question_instance.questions.roots.find(:all, :order => 'updated_at desc', :limit => 1).id
  rescue Exception => e
    render :text => ''
  end

  def is_owner
    question_instance = QuestionInstance.find(params[:id])
    render :json => current_user.has_role?(:owner, question_instance)
  rescue Exception => e
    render :text => "Sorry, there's been an error", :status => :server_error
  end

  # GET /question_instances/1
  # GET /question_instances/1.xml
  def show
    if params[:sort].blank?
      params[:sort] = cookies[:sort]
    end
    @question_instance = QuestionInstance.find(params[:id])

    respond_to do |format|
      format.html {render :layout => (request.xhr?) ? false : true} 
      format.xml  { render :xml => @question_instance }
    end
  end

  # GET /question_instances/new
  # GET /question_instances/new.xml
  def new
    add_stylesheets ["formtastic","forms"]
    @question_instance = QuestionInstance.new

    respond_to do |format|
      format.html { render :partial => 'shared/forms/question_instance', :layout => false} 
      format.xml  { render :xml => @question_instance }
    end
  end

  # GET /question_instances/1/edit
  def edit
    add_stylesheets ["formtastic","forms"]
    respond_to do |format|
      format.html { render :partial => 'shared/forms/question_instance', :layout => false} 
      format.xml  { render :xml => @question_instance }
    end
  end

  # POST /question_instances
  # POST /question_instances.xml
  def create
    add_stylesheets ["formtastic","forms"]
    @question_instance = QuestionInstance.new(params[:question_instance])
    @question_instance.accepts_role!(:owner, current_user)
    respond_to do |format|
      if @question_instance.save
        @UPDATE_QUESTION_INSTANCE_TIME = @question_instance
        flash[:notice] = 'QuestionInstance was successfully created.'
        format.html { render :text => @question_instance.id, :layout => false }
        format.xml  { render :xml => @question_instance, :status => :created, :location => @question_instance }
      else
        format.html { render :text => "We couldn't add that question instance. Sorry!<br/>#{@question_instance.errors.full_messages.join('<br/')}", :status => :unprocessable_entity }
        format.xml  { render :xml => @question_instance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /question_instances/1
  # PUT /question_instances/1.xml
  def update
    add_stylesheets ["formtastic","forms"]
    @question_instance = QuestionInstance.find(params[:id])

    respond_to do |format|
      if @question_instance.update_attributes(params[:question_instance])
        @UPDATE_QUESTION_INSTANCE_TIME = @question_instance
        flash[:notice] = 'Question Instance was successfully updated.'
        format.html { render :text => @question_instance.id, :layout => false }
        format.xml  { head :ok }
      else
        format.html { render :text => "We couldn't update that question instance. Sorry!<br/>#{@question_instance.errors.full_messages.join('<br/')}", :status => :unprocessable_entity }
        format.xml  { render :xml => @question_instance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /question_instances/1
  # DELETE /question_instances/1.xml
  def destroy
    @question_instance.destroy

    respond_to do |format|
      format.html { redirect_to(question_instances_url) }
      format.xml  { head :ok }
    end
  end

  private

  def load_question_instance
    @question_instance = QuestionInstance.find(params[:id])
  end

  def prep_resources
    #Time.zone = 'London'
    @logo_title = 'Question Tool'
    add_stylesheets 'question_tool'
    add_javascripts 'question_tool'
  end

end
