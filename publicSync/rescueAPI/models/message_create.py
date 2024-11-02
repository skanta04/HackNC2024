from pydantic import BaseModel
from enum import Enum

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

class MessageCreate(BaseModel):
    content: str
    latitude: float
    longitude: float
    status: MessageStatus
    category: MessageCategory

class Config:
        orm_mode = True

