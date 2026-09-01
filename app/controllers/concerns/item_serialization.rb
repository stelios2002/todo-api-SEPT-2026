module ItemSerialization
  extend ActiveSupport::Concern

  private

  def item_json(item)
    {
      id: item.id,
      todo_id: item.todo_id,
      content: item.content,
      completed: item.completed,
      position: item.position,
      created_at: item.created_at,
      updated_at: item.updated_at
    }
  end
end