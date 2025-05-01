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
@app.route('/', methods=['POST'])
def generate_speech():
    # 获取客户端发送的文本
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
        
        # 将API返回的音频数据作为文件返回给客户端
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

# 在app/app.py中添加以下代码

import os
import uuid
from datetime import datetime
from flask import Flask, request, send_file, jsonify, url_for

# 确保存储目录存在
UPLOAD_FOLDER = os.path.join(os.path.dirname(__file__), 'uploads')
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# 确保uploads文件夹在app中可以访问
@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_file(os.path.join(UPLOAD_FOLDER, filename))

@app.route('/upload-image', methods=['POST'])
def upload_image():
    # 检查是否有文件在请求中
    if 'image' not in request.files:
        return jsonify({"error": "No image part in the request"}), 400
    
    file = request.files['image']
    
    # 如果用户没有选择文件
    if file.filename == '':
        return jsonify({"error": "No image selected"}), 400
    
    # 确保文件名是安全的，并使用UUID确保唯一性
    file_ext = os.path.splitext(file.filename)[1].lower()
    if file_ext not in ['.jpg', '.jpeg', '.png']:
        return jsonify({"error": "File type not allowed"}), 400
    
    # 创建唯一文件名
    unique_filename = f"{uuid.uuid4().hex}{file_ext}"
    file_path = os.path.join(UPLOAD_FOLDER, unique_filename)
    
    # 保存文件
    file.save(file_path)
    
    # 构造图片URL (使用当前主机名)
    image_url = request.host_url.rstrip('/') + url_for('uploaded_file', filename=unique_filename)
    
    return jsonify({
        "success": True, 
        "file_name": unique_filename,
        "url": image_url
    })

@app.route('/get-image/<filename>', methods=['GET'])
def get_image(filename):
    file_path = os.path.join(UPLOAD_FOLDER, filename)
    
    # 检查文件是否存在
    if not os.path.exists(file_path):
        return jsonify({"error": "Image not found"}), 404
    
    # 返回图片文件
    return send_file(file_path)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
