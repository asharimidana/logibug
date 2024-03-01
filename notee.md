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

curl --location --insecure --request
POST 'https://api.openai.com/v1/chat/completions'
--header 'Authorization: Bearer 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'
--header 'Content-Type: application/json'
--data-raw
'{ "model": "gpt-3.5-turbo", "messages": [{"role": "user", "content": "urutkan angka ini [{1,8,5,,2}, {2,3,9,1}] dan buatkan dalam bentuk array"}] }'
