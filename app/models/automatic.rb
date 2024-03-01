class Automatic < ApplicationRecord
  require 'uri'
  require 'net/http'
  belongs_to :version
  mount_uploader :json_url, JsonUploader

  validates :json_url, presence: true
  validates :version_id, presence: true, uniqueness: true

  def self.new_attr(data)
    {
      id: data[:id],
      version_id: data[:version_id],
      method: data[:method],
      folder_name: data[:folder_name],
      req_name: data[:req_name],
      folder: data[:folder]
    }
  end

  # Run by request
  def self.run_by_req(json_data)
    req = json_data

    url = req[:request]['url']['raw']
    url = URI(url)
    https = Net::HTTP.new(url.host, url.port)

    https.use_ssl = true
    request = Automatic.req_method(req[:request]['method'], url)
    response = https.request(request)

    res_data = { id: json_data[:id], version_id: json_data[:version_id], method: json_data[:method],
                 folder_name: json_data[:folder_name], req_name: json_data[:req_name], folder: json_data[:folder] }
    res_data['response'] = { code: response.code }
    res_data
  rescue
    false
  end

  def self.req_method(method, url)
    case method
    when 'POST'
      Net::HTTP::Post.new(url)
    when 'GET'
      Net::HTTP::Get.new(url)
    when 'PUT'
      Net::HTTP::Put.new(url)
    when 'DELETE'
      Net::HTTP::Delete.new(url)
    when 'PATCH'
      Net::HTTP::Patch.new(url)
    else
      false
    end
  end
end
