import requests
from ..core.config import settings

class AnalysisService:
    def __init__(self):
        self.api_key = settings.DEEPSEAK_API_KEY
        self.base_url = "https://api.deepseak.com/v1"

    async def analyze_text(self, text: str) -> str:
        """
        Analyze text using Deepseak API
        """
        try:
            headers = {
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json"
            }
            
            response = requests.post(
                f"{self.base_url}/analyze",
                headers=headers,
                json={"text": text}
            )
            
            response.raise_for_status()
            return response.json()["analysis"]
        except Exception as e:
            raise Exception(f"Error analyzing text: {str(e)}") 