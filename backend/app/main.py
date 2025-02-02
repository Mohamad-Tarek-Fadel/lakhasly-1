from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .api.endpoints import audio

app = FastAPI(title="Audio Processing API")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust this in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(audio.router, prefix="/api") 