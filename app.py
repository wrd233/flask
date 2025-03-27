from flask import Flask, request, send_file
from flask_cors import CORS
import requests
import os
from dotenv import load_dotenv
from io import BytesIO

# 加载环境变量
load_dotenv()

app = Flask(__name__)
CORS(app)  # 允许跨域请求

@app.route('/generate-speech', methods=['POST'])
def generate_speech():
    # 获取iOS客户端发送的description
    data = request.json
    if not data or 'text' not in data:
        return {"error": "No text provided"}, 400
    
    text = data['text']
    
    # 文本太长会导致API错误，限制长度
    if len(text) > 1000:
        text = text[:1000] + "..."
    
    # 调用OpenAI API生成语音
    openai_api_key = os.getenv('OPENAI_API_KEY')
    if not openai_api_key:
        return {"error": "API key not configured"}, 500
    
    headers = {
        "Authorization": f"Bearer {openai_api_key}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "model": "gpt-4o-mini-tts",
        "input": text,
        "voice": "coral",
        "instructions": "Speak in a cheerful and positive tone."
    }
    
    try:
        response = requests.post(
            "https://api.openai.com/v1/audio/speech",
            headers=headers,
            json=payload
        )
        
        # 检查API响应
        if response.status_code != 200:
            return {"error": f"OpenAI API error: {response.text}"}, 500
        
        # 将API返回的音频数据作为文件返回给iOS客户端
        audio_data = BytesIO(response.content)
        audio_data.seek(0)
        
        return send_file(
            audio_data,
            mimetype="audio/mpeg",
            as_attachment=True,
            download_name="speech.mp3"
        )
    
    except Exception as e:
        return {"error": f"Server error: {str(e)}"}, 500

if __name__ == '__main__':
    # 在生产环境中，不要使用debug=True
    app.run(host='0.0.0.0', port=5000)