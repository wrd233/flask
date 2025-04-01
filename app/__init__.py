from flask import Flask

def create_app(config_name='default'):
    app = Flask(__name__)
    
    # 导入配置
    from config import config
    app.config.from_object(config[config_name])
    
    # 注册蓝图
    from app.routes import main as main_blueprint
    app.register_blueprint(main_blueprint)
    
    return app
