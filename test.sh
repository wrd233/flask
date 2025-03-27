#!/bin/bash
# 请将 YOUR_API_KEY 替换为你实际的 OpenAI API 密钥

# curl https://api.openai.com/v1/audio/speech \
#   -H "Authorization: Bearer ${API_KEY}" \
#   -H "Content-Type: application/json" \
#   -d '{
#     "model": "gpt-4o-mini-tts",
#     "input": "Today is a wonderful day to build something people love!",
#     "voice": "coral",
#     "instructions": "Speak in a cheerful and positive tone."
#   }' \
#   --output speech.mp3


  curl https://api.openai.com/v1/images/generations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "model": "dall-e-3",
    "prompt": "a white siamese cat",
    "n": 1,
    "size": "1024x1024"
  }'
