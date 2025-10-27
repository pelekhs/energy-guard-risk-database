from sqlalchemy import inspect

from app.db.models import Base
from app.db.session import engine


def init_db() -> None:
    inspector = inspect(engine)
    if not inspector.has_table("risk"):
        Base.metadata.create_all(bind=engine)
    else:
        Base.metadata.create_all(bind=engine)


if __name__ == "__main__":
    init_db()
