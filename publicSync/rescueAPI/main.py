from fastapi import FastAPI
from sqlmodel import SQLModel
from database import engine, get_db_session
from sqlalchemy.orm import Session
from models.message_create import MessageCreate
from models.message_details import MessageDetails
from services.message_service import MessageService
from fastapi import HTTPException, Depends
from typing import List

# Initialize FastAPI app
app = FastAPI()

# Instantiate MessageService
message_service = MessageService()

# Create tables on application startup
@app.on_event("startup")
def on_startup():
    """Create tables at application startup if they do not exist."""
    SQLModel.metadata.create_all(engine)

# Create a new message
@app.post("/messages/", response_model=MessageDetails)
def create_message(message_data: MessageCreate, db: Session = Depends(get_db_session)):
    try:
        return message_service.create_message(message_data, db)
    except Exception as e:
        print(f"Error occurred during message creation: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error while creating the message.")

# Get all messages
@app.get("/messages/", response_model=List[MessageDetails])
def read_messages(db: Session = Depends(get_db_session)):
    try:
        return message_service.get_all_messages(db)
    except Exception as e:
        print(f"Error occurred while fetching messages: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error while fetching messages.")

# Delete a message by ID
@app.delete("/messages/{message_id}")
def delete_message(message_id: int, db: Session = Depends(get_db_session)):
    try:
        if not message_service.delete_message(message_id, db):
            raise HTTPException(status_code=404, detail="Message not found")
        return {"detail": "Message deleted successfully"}
    except Exception as e:
        db.rollback()
        print(f"Error occurred while deleting the message with ID {message_id}: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error while deleting the message.")

