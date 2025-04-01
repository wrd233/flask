#!/bin/bash

# 创建项目结构
mkdir -p app/static app/templates

# 创建 app.py
cat > app/app.py << 'EOF'
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

@app.route('/')
def hello_world():
    return 'Hello, World! Text-to-Speech API is running.'

@app.route('/generate-speech', methods=['POST'])
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

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
EOF

# 创建 wsgi.py
cat > wsgi.py << 'EOF'
from app.app import app

if __name__ == "__main__":
    app.run(host='0.0.0.0')
EOF

# 创建 requirements.txt
cat > requirements.txt << 'EOF'
flask==2.3.3
gunicorn==21.2.0
flask-cors==4.0.0
requests==2.31.0
python-dotenv==1.0.0
EOF

# 创建 Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "wsgi:app"]
EOF

# 创建 .dockerignore
cat > .dockerignore << 'EOF'
__pycache__/
*.py[cod]
*$py.class
*.so
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/
.git
.gitignore
.pytest_cache/
EOF

# 创建 .env.example 文件
cat > .env.example << 'EOF'
# OpenAI API Key
OPENAI_API_KEY=your_openai_api_key_here
EOF

# 创建 .gitignore
cat > .gitignore << 'EOF'
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# Virtual Environment
venv/
env/
ENV/

# IDE files
.idea/
.vscode/

# Local development settings
.env
.env.local
.env.development

# Docker
.docker/
EOF

# 创建 README.md
cat > README.md << 'EOF'
# Flask Hello World

一个简单的 Flask Hello World 应用，配置了 Docker 和 Zeabur 部署支持。

## 本地开发

1. 创建虚拟环境:
   ```
   python -m venv venv
   source venv/bin/activate  # 在 Windows 上使用: venv\Scripts\activate
   ```

2. 安装依赖:
   ```
   pip install -r requirements.txt
   ```

3. 运行应用:
   ```
   python wsgi.py
   ```

4. 访问 http://localhost:5000

## Docker 构建与运行

1. 构建 Docker 镜像:
   ```
   docker build -t flask-hello-world .
   ```

2. 运行容器:
   ```
   docker run -p 8000:8000 flask-hello-world
   ```

3. 访问 http://localhost:8000

## 部署到 Zeabur

1. 将代码推送到 GitHub 仓库
2. 在 Zeabur 上连接 GitHub 仓库
3. Zeabur 会自动检测 Dockerfile 并构建部署

EOF

# 创建 zeabur.json 配置文件
cat > zeabur.json << 'EOF'
{
  "builds": [
    {
      "src": ".",
      "use": "@zeabur/dockerfile"
    }
  ]
}
EOF

# 将脚本设为可执行
chmod +x setup.sh

echo "Flask 文本转语音 API 项目已成功生成！"
echo ""
echo "重要: 您需要创建一个 .env 文件并添加您的 OpenAI API Key"
echo "cp .env.example .env  # 然后编辑 .env 文件添加您的 API Key"
echo ""
echo "您可以使用以下命令开始开发："
echo "1. 创建虚拟环境: python -m venv venv"
echo "2. 激活虚拟环境: source venv/bin/activate (Windows: venv\\Scripts\\activate)"
echo "3. 安装依赖: pip install -r requirements.txt"
echo "4. 运行应用: python wsgi.py"
echo "5. 访问: http://localhost:5000"
echo ""
echo "API 使用示例:"
echo "curl -X POST http://localhost:5000/generate-speech \\"
echo "     -H \"Content-Type: application/json\" \\"
echo "     -d '{\"text\":\"Hello world\"}' \\"
echo "     --output speech.mp3"