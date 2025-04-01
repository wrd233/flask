#!/usr/bin/env python3
"""
Flask Zeabur项目生成脚本 - 在当前目录创建项目结构
"""

import os
import sys
import subprocess

# 文件内容定义
FILES = {
    "app/__init__.py": """from flask import Flask

def create_app(config_name='default'):
    app = Flask(__name__)
    
    # 导入配置
    from config import config
    app.config.from_object(config[config_name])
    
    # 注册蓝图
    from app.routes import main as main_blueprint
    app.register_blueprint(main_blueprint)
    
    return app
""",

    "app/routes.py": """from flask import Blueprint, render_template

main = Blueprint('main', __name__)

@main.route('/')
def index():
    return render_template('index.html')
""",

    "app/templates/index.html": """<!DOCTYPE html>
<html>
<head>
    <title>Flask Hello World</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            margin-top: 100px;
        }
        h1 {
            color: #333;
        }
    </style>
</head>
<body>
    <h1>Hello, World!</h1>
    <p>Successfully deployed Flask app on Zeabur!</p>
</body>
</html>
""",

    "config.py": """import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'hard-to-guess-string'

class DevelopmentConfig(Config):
    DEBUG = True

class ProductionConfig(Config):
    DEBUG = False

config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}
""",

    "wsgi.py": """import os
from app import create_app

# 根据环境变量选择配置
config_name = os.environ.get('FLASK_CONFIG') or 'default'
app = create_app(config_name)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))
""",

    "requirements.txt": """Flask==2.2.3
gunicorn==20.1.0
""",

    "Procfile": """web: gunicorn wsgi:app
""",

    "runtime.txt": """python-3.10.12
""",

    ".gitignore": """# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
*.egg-info/
.installed.cfg
*.egg

# Virtual Environment
venv/
ENV/

# IDE files
.idea/
.vscode/
*.swp
*.swo

# OS specific files
.DS_Store
Thumbs.db
""",

    "README.md": """# Flask Hello World for Zeabur

一个简单的 Flask Hello World 应用，专为 Zeabur 部署优化。

## 本地开发

1. 创建并激活虚拟环境:
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # 在 Windows 上使用: venv\\Scripts\\activate
   ```

2. 安装依赖:
   ```bash
   pip install -r requirements.txt
   ```

3. 运行应用:
   ```bash
   python3 wsgi.py
   ```

4. 访问 http://127.0.0.1:5000

## 在 Zeabur 上部署

1. 创建一个 Zeabur 项目
2. 连接你的 GitHub 仓库
3. 部署应用

Zeabur 会自动检测到 Flask 应用并进行部署。
"""
}

def main():
    print("开始创建Flask Zeabur项目...")
    
    # 创建目录结构
    os.makedirs("app/templates", exist_ok=True)
    
    # 创建所有文件
    for filepath, content in FILES.items():
        # 确保目录存在
        dirname = os.path.dirname(filepath)
        if dirname and not os.path.exists(dirname):
            os.makedirs(dirname, exist_ok=True)
            
        # 写入文件内容
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"创建文件: {filepath}")
    
    print("\n项目创建完成!")
    print("推荐的后续步骤:")
    print("1. 创建并激活虚拟环境:")
    if sys.platform == 'win32':
        print("   python3 -m venv venv")
        print("   venv\\Scripts\\activate")
    else:
        print("   python3 -m venv venv")
        print("   source venv/bin/activate")
    
    print("2. 安装依赖:")
    print("   pip install -r requirements.txt")
    
    print("3. 运行应用:")
    print("   python3 wsgi.py")
    
    print("4. 将代码提交到GitHub并在Zeabur上部署")
    
    # 询问是否要立即创建虚拟环境并安装依赖
    setup_now = input("\n是否现在创建虚拟环境并安装依赖? (y/n): ").strip().lower()
    if setup_now == 'y':
        try:
            # 创建虚拟环境
            print("\n创建虚拟环境...")
            subprocess.run([sys.executable, "-m", "venv", "venv"], check=True)
            
            # 激活虚拟环境并安装依赖
            print("安装依赖...")
            if sys.platform == 'win32':
                activate_cmd = ".\\venv\\Scripts\\activate && pip install -r requirements.txt"
                subprocess.run(activate_cmd, shell=True, check=True)
            else:
                activate_cmd = "source ./venv/bin/activate && pip install -r requirements.txt"
                subprocess.run(activate_cmd, shell=True, executable='/bin/bash', check=True)
                
            print("\n设置完成! 你现在可以运行 'python3 wsgi.py' 启动应用。")
        except subprocess.CalledProcessError as e:
            print(f"设置过程中出错: {e}")
            print("请手动创建虚拟环境并安装依赖。")

if __name__ == "__main__":
    main()