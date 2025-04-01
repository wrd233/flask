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

