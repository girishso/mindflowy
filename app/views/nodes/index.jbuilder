json.array!(@nodes) do |node|
  json.extract! node, :id, :title, :user_id
  json.url node_url(node, format: :json)
end

