class BaseController < ApplicationController
  def playlist_admin_preload
    if current_user
      @playlist_admin = current_user.roles.find(:all, :conditions => {:authorizable_type => nil, :name => ['admin','playlist_admin','superadmin']}).length > 0
      @playlists_i_can_edit = current_user.playlists_i_can_edit
    end
  end

  def embedded_pager(model = Case)
    @objects = Sunspot.new_search(model)
    @objects.build do
      unless params[:keywords].blank?
        keywords params[:keywords]
      end
      paginate :page => params[:page], :per_page => cookies[:per_page] || nil
      #      data_accessor_for(model).include = [:tags, :collages, :case_citations]
      order_by :display_name, :asc
    end

    @objects.execute!
    respond_to do |format|
      format.html { render :partial => 'shared/playlistable_item', :object => model }
      format.js { render :partial => 'shared/playlistable_item', :object => model }
      format.xml { render :xml => @objects }
    end
  end

  def index
    tcount = Case.find_by_sql("SELECT COUNT(*) AS tcount FROM taggings")
    @counts = {
		:cases => Case.count,
		:text_blocks => TextBlock.count,
		:collages => Collage.count,
		:annotation => Annotation.count,
		:questions => Question.count,
		:rotisseries => RotisserieInstance.count,
		:taggings => tcount[0]['tcount'] 
	}
  end

  def search
    @playlists = Sunspot.new_search(Playlist)
	@collages = Sunspot.new_search(Collage)

	if !params.has_key?(:sort)
	  params[:sort] = "display_name"
	end

    sort_base_url = ''
	@playlists.build do
	  if params.has_key?(:keywords)
	    keywords params[:keywords]
		sort_base_url += "&keywords=#{params[:keywords]}"
	  end
	  with :public, true
	  paginate :page => params[:page], :per_page => cookies[:per_page] || nil
	  order_by params[:sort].to_sym, :asc
	end
	@collages.build do
	  if params.has_key?(:keywords)
	    keywords params[:keywords]
		sort_base_url += "&keywords=#{params[:keywords]}"
	  end
	  with :public, true
	  with :active, true
	  paginate :page => params[:page], :per_page => cookies[:per_page] || nil

	  # FIGURE OUT IF THE FOLLOWING LINE IS NEEDED
	  data_accessor_for(Collage).include = {:annotations => {:layers => []}, :accepted_roles => {}, :annotatable => {}}

	  order_by params[:sort].to_sym, :asc
	end

    @collages.execute!
	@playlists.execute!

	if current_user
	  @is_collage_admin = current_user.roles.find(:all, :conditions => {:authorizable_type => nil, :name => ['admin','collage_admin','superadmin']}).length > 0
	  @my_collages = current_user.collages
	  @my_playlists = current_user.playlists.select { |p| p.id != current_user.bookmark_id }
	else
	  @is_collage_admin = false
	  @my_collages = []
	  @my_playlists = []
	end

    playlist_admin_preload

    generate_sort_list("/search?#{sort_base_url}",
		{	"display_name" => "DISPLAY NAME",
			"created_at" => "BY DATE",
			"author" => "BY AUTHOR"	}
		)
  end
end
