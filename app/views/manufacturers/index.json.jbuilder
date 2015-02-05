json.array!(@manufacturers) do |manufacturer|
  json.extract! manufacturer, :id, :name, :address, :website, :main_phone, :main_fax, :tags
  json.url manufacturer_url(manufacturer, format: :json)
end
