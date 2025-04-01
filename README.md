# Flask Hello World for Zeabur

一个简单的 Flask Hello World 应用，专为 Zeabur 部署优化。

## 本地开发

1. 创建并激活虚拟环境:
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # 在 Windows 上使用: venv\Scripts\activate
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
