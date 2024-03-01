class Api::V1::ApiController < ApplicationController
  require 'uri'
  require 'net/http'
  def run_http
    url = URI('https://logibugv2.fly.dev/api/v1/users')

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)

    response = https.request(request)
    puts response.read_body
  end

end
