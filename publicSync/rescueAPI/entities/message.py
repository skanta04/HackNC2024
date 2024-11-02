from sqlmodel import SQLModel, Field
from typing import Optional
from enum import Enum
from datetime import datetime, timezone

class MessageStatus(str, Enum):
    pending_sync = "pending_sync"
    synced = "synced"

class MessageCategory(str, Enum):
    road_closure = "Road Closure"
    flooding = "Flooding"
    shelter = "Shelter"
    resource = "Resource"
    sos = "SOS"
    other = "Other"

class Message(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    content: str
    latitude: float
    longitude: float
    timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))  
    status: MessageStatus
    category: MessageCategory


