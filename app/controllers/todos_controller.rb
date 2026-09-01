class TodosController < ApplicationController
  before_action :authorize_request
  before_action :set_todo, only: [:show, :update, :destroy]

  # GET /todos
  def index
    todos = current_user.todos.recent
    render json: { count: todos.size, todos: todos.map { |t| todo_json(t) } }, status: :ok
  end

  # GET /todos/:id
  def show
    render json: { todo: todo_json(@todo) }, status: :ok
  end

  # POST /todos
  def create
    todo = current_user.todos.new(todo_params)

    if todo.save
      render json: { message: "Todo created", todo: todo_json(todo) }, status: :created
    else
      render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /todos/:id
  def update
    if @todo.update(todo_params)
      render json: { message: "Todo updated", todo: todo_json(@todo) }, status: :ok
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /todos/:id
  def destroy
    @todo.destroy
    render json: { message: "Todo deleted" }, status: :ok
  end

  private

  def set_todo
    @todo = current_user.todos.find(params[:id])
  end

  def todo_params
    params.permit(:title, :description, :completed)
  end

  def todo_json(todo)
    {
      id: todo.id,
      title: todo.title,
      description: todo.description,
      completed: todo.completed,
      items_count: todo.items.size,
      created_at: todo.created_at,
      updated_at: todo.updated_at
    }
  end
end