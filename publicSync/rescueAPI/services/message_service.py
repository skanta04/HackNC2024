from sqlalchemy.orm import Session
from entities.message import Message
from models.message_create import MessageCreate
from typing import List
from models.message_create import MessageStatus

class MessageService:
    def create_message(self, message_data: MessageCreate, db: Session) -> Message:
        db_message = Message(**message_data.dict())
        db.add(db_message)
        db.commit()
        db.refresh(db_message)
        return db_message

    def get_all_messages(self, db: Session) -> List[Message]:
        return db.query(Message).all()

    def delete_message(self, message_id: int, db: Session) -> bool:
        db_message = db.query(Message).filter(Message.id == message_id).first()
        if db_message:
            db.delete(db_message)
            db.commit()
            return True
        return False
    
    def update_message_status(self, message_id: int, status: MessageStatus, db: Session) -> Message:
        db_message = db.query(Message).filter(Message.id == message_id).first()
        if db_message:
            db_message.status = status
            db.commit()
            db.refresh(db_message)
            return db_message
        return None

