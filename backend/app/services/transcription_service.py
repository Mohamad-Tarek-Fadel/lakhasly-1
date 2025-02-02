import whisper
import os
from pathlib import Path

class TranscriptionService:
    def __init__(self):
        self.model = whisper.load_model("base")

    async def transcribe_audio(self, file_path: str) -> str:
        """
        Transcribe audio file using OpenAI Whisper
        """
        try:
            result = self.model.transcribe(file_path)
            return result["text"]
        except Exception as e:
            raise Exception(f"Error transcribing audio: {str(e)}") 