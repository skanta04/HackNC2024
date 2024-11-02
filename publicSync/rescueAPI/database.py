from sqlmodel import SQLModel, create_engine, Session
import os
from dotenv import load_dotenv

# Load environment variables from the .env file
load_dotenv()

# Fetch the DATABASE_URL from the environment variables
DATABASE_URL = os.getenv("DATABASE_URL")

# Create the database engine for PostgreSQL
engine = create_engine(DATABASE_URL, echo=True)

# Dependency to get DB session
def get_db_session():
    """Generator function to provide the database session in FastAPI dependencies."""
    with Session(engine) as session:
        yield session

# Function to create the tables
def create_tables():
    """Creates tables based on SQLModel models if they don't exist."""
    SQLModel.metadata.create_all(engine)

# Run create_tables when this file is executed
if __name__ == "__main__":
    create_tables()


