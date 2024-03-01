class Api::V1::AiController < ApplicationController
  require 'uri'
  require 'json'
  require 'net/http'
  # scenario name, pre condition, test step, expectation

  def run_ai
    url = URI('https://api.openai.com/v1/chat/completions')

    https = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Post.new(url)
    https.use_ssl = true

    request['Authorization'] = 'Bearer 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'
    request['Content-Type'] = 'application/json'
    content = "please create testcase #{ai_params[:data]}"
    request.body = JSON.dump({
                               model: 'gpt-3.5-turbo',
                               "messages": [{
                                 "role": 'user',
                                 "content": content
                               }],
                               max_tokens: 350,
                               temperature: 0
                             })

    response = https.request(request)
    data = JSON.parse(response.read_body)
    chat_gpt = data['choices'][0]['message']['content']
    testcase = chat_gpt.split('Test Case:').last.split("\n\n").first
    precond = chat_gpt.split("Preconditions:\n").last.split("\n\n").first
    step = chat_gpt.split("Test Steps:\n").last.split("\n\n").first
    expectation = chat_gpt.split("Expected Results:\n").last.split("\n\n").first
    res = {
      testcase:,
      precond:,
      step:,
      expectation:
    }

    # binding.pry
    render json: { message: "success", data: res}, status: 200
    # render json: { data: }, status: 200
  # rescue StandardError
  #   render json: { errors: 'pleas try again' }, status: 422
  end

  private

  def ai_params
    params.permit(:data)
  end
end
