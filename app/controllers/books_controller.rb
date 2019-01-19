class BooksController < ApplicationController
  def index
    if !params.key?(:genres)
        params[:genres] = {}
    end
    permitted = params.permit(:sort, ratings: params[:genres].keys)
    sort = permitted[:sort] || session[:sort]

    case sort
    when 'title'
      ordering,@title_header = {:title => :asc}, 'hilite'
    when 'release_date'      
      ordering,@date_header = {:publish_date => :asc}, 'hilite'
    end
    
    @all_genres = Book.all_genres  
    @selected_genres = params[:genres]|| {}
    @selected_genres = permitted[:genres] || session[:genres] || {}
    if @selected_genres == {}  
        @selected_genres = Hash[@all_genres.map {|genre| [genre, genre]}]
    end

    if permitted[:sort] != session[:sort] or permitted[:ratings] != session[:genres]
        session[:sort] = sort
        session[:genres] = @selected_genres
        redirect_to :sort => sort, :genres => @selected_genres and return
    end
    
    @books = Book.where(genre: @selected_genres.keys).order(ordering)
  end
  
  def show
    id = params[:id] # retrieve book ID from URI route
    @book = Book.find(id) # look up book by unique ID
    # will render app/views/books/show.html.haml by default
  end
  
  def new
    @book = Book.new
    # default: render 'new' template
  end
  
  def create
    params.require(:book)
    permitted = params[:book].permit(:title,:genre,:publish_date,:isbn,:description)
    @book = Book.new(permitted)
    
    if @book.save
        flash[:notice] = "#{@book.title} was successfully created."
        redirect_to books_path
    else
        render 'new' # note, 'new' template can access @book's field values!
    end
  end
 
  def edit
    @book = Book.find params[:id]
  end

  def update
    @book = Book.find params[:id]
    params.require(:book)
    permitted = params[:book].permit(:title,:genre,:publish_date,:isbn,:description)
    @book.update_attributes(permitted)
    
    if @book.save
        flash[:notice] = "#{@book.title} was successfully updated."
        redirect_to books_path
    else
        render 'edit' # note, 'edit' template can access @book's field values!
    end
  end
  
  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    flash[:notice] = "Book '#{@book.title}' deleted."
    redirect_to books_path
  end

end