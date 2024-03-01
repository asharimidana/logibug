module ReadApi
  #===============================================
  def self.get_collection(data)
    json_url = data.json_url.url
    json_data = JSON.parse(
      File.read("#{Rails.root}/public/#{json_url}")
    )
    id = 0
    res_data = []
    json_data['item'].map do |item|
      if item['item'].nil? == false
        child_folder = item['item']
        child_folder.map do |req|
          id += 1
          method = child_folder[0]['request']['method']
          res_data.append({ id:, version_id: data.version_id, method:, folder_name: item['name'], req_name: req['name'],
                            folder: true, request: req['request'] })
        end
      else
        id += 1
        method = item['request']['method']
        res_data.append({ id:, method:, version_id: data.version_id, folder_name: nil, req_name: item['name'], folder: false,
                          request: item['request'] })
      end
    end
    res_data
  rescue StandardError
    nil
  end

  def self.run_collection(data)
    json_url = data.json_url.url
    x = JSON.parse(
      File.read("#{Rails.root}/public/#{json_url}")
    )
    x['item'].map do |item, x|
      if item['item'].nil? == false
        child_folder = item['item']
        child_data = child_folder.map do |req|
          { id: child_folder.find_index(req) + 1, name: req['name'], folder: false, request: req['request'] }
        end

        { id: x['item'].find_index(item) + 1, name: item['name'], folder: true, child_forder: child_data }
      else
        { id: x['item'].find_index(item) + 1, name: item['name'],
          folder: false, request: item['request'] }
      end
    end
  rescue StandardError
    nil
  end
end
