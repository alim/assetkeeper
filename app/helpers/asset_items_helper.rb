module AssetItemsHelper

  #####################################################################
  # The asset items search_options method returns an options_for_select
  # grouping for searching assets by manufacturer
  #####################################################################
  def asset_items_search_options
    return options_for_select([
      ['Manufacturer', 'manufacturer_id'],
      ['Tags', 'tags']
    ]
    )
  end

end

