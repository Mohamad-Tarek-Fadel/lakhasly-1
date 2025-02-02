from pydenv import BaseSettings

class Settings(BaseSettings):
    DEEPSEAK_API_KEY: str
    UPLOAD_DIR: str = "uploads"

    class Config:
        env_file = ".env"

settings = Settings() 