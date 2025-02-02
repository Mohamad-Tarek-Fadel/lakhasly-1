from fastapi import APIRouter, UploadFile, File, HTTPException
from ...services.transcription_service import TranscriptionService
from ...services.analysis_service import AnalysisService
import os
from pathlib import Path
from ...core.config import settings

router = APIRouter()
transcription_service = TranscriptionService()
analysis_service = AnalysisService()

@router.post("/process_audio")
async def process_audio(file: UploadFile = File(...)):
    try:
        # Create uploads directory if it doesn't exist
        upload_dir = Path(settings.UPLOAD_DIR)
        upload_dir.mkdir(exist_ok=True)
        
        # Save uploaded file
        file_path = upload_dir / file.filename
        with open(file_path, "wb") as buffer:
            content = await file.read()
            buffer.write(content)
        
        # Process the audio
        try:
            # Transcribe audio
            transcription = await transcription_service.transcribe_audio(str(file_path))
            
            # Analyze transcribed text
            analysis = await analysis_service.analyze_text(transcription)
            
            # Clean up
            os.remove(file_path)
            
            return {
                "transcription": transcription,
                "analysis": analysis
            }
        
        except Exception as e:
            # Clean up in case of error
            if file_path.exists():
                os.remove(file_path)
            raise e
            
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        ) 