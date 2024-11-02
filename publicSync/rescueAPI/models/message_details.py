from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class MessageDetails(BaseModel):
    id: Optional[int]
    content: str
    latitude: float
    longitude: float
    timestamp: datetime  # Expecting a datetime object here, with timezone awareness
    status: str
    category: str

    class Config:
        from_attributes = True  # Replaces orm_mode

