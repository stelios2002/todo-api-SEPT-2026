class ItemsController < ApplicationController
  include ItemSerialization
  before_action :authorize_request
  before_action :set_todo
  before_action :set_item, only: %i[show update destroy]

  # GET /todos/:todo_id/items
  def index
    items = @todo.items.ordered
    render json: {
      todo_id: @todo.id,
      count: items.size,
      items: items.map { |i| item_json(i) }
    }, status: :ok
  end

  # GET /todos/:todo_id/items/:id
  def show
    render json: item_json(@item), status: :ok
  end

  # POST /todos/:todo_id/items
  def create
    item = @todo.items.new(item_params)
    item.position ||= next_position

    if item.save
      render json: item_json(item), status: :created
    else
      render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /todos/:todo_id/items/:id
  def update
    if @item.update(item_params)
      render json: item_json(@item), status: :ok
    else
      render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /todos/:todo_id/items/:id
  def destroy
    @item.destroy
    render json: { message: "Item deleted" }, status: :ok
  end

  private

  def set_todo
    @todo = current_user.todos.find(params[:todo_id])
  end

  def set_item
    @item = @todo.items.find(params[:id])
  end

  def next_position
    (@todo.items.maximum(:position) || 0) + 1
  end

  def item_params
    params.permit(:content, :completed, :position)
  end
end