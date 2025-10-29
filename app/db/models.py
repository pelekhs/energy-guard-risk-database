from sqlalchemy import (
    CheckConstraint,
    Column,
    DateTime,
    ForeignKey,
    Index,
    Integer,
    JSON,
    String,
    Text,
    event,
    text,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import declarative_base, relationship

Base = declarative_base()


class Risk(Base):
    __tablename__ = "risk"

    risk_id = Column(String, primary_key=True)
    status = Column(String, nullable=True)
    version = Column(String, nullable=True)
    card = Column(JSONB().with_variant(JSON, "sqlite"), nullable=False)
    created_at = Column(DateTime, server_default=text("NOW()"), nullable=False)
    updated_at = Column(DateTime, server_default=text("NOW()"), nullable=False)

    categories = relationship("RiskCategory", back_populates="risk", cascade="all, delete-orphan")
    contexts = relationship("RiskContext", back_populates="risk", cascade="all, delete-orphan")


class Category(Base):
    __tablename__ = "category"

    category_id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    parent_category_id = Column(String, ForeignKey("category.category_id"), nullable=True)

    parent = relationship("Category", remote_side=[category_id])


class EnergyContext(Base):
    __tablename__ = "energy_context"

    context_id = Column(String, primary_key=True)
    name = Column(String, nullable=False, unique=True)
    description = Column(Text, nullable=True)
    criticality_level = Column(Integer, CheckConstraint("criticality_level BETWEEN 1 AND 5"), nullable=False)


class RiskCategory(Base):
    __tablename__ = "risk_category"
    __table_args__ = (
        CheckConstraint("assignment_type <> ''", name="chk_assignment_type"),
        Index("risk_category_risk_id_idx", "risk_id"),
        Index("risk_category_category_id_idx", "category_id"),
        {
            "postgresql_partition_by": None,
        },
    )

    risk_id = Column(String, ForeignKey("risk.risk_id", ondelete="CASCADE"), primary_key=True)
    category_id = Column(String, ForeignKey("category.category_id", ondelete="CASCADE"), primary_key=True)
    assignment_type = Column(String, nullable=False, default="primary")

    risk = relationship("Risk", back_populates="categories")
    category = relationship("Category")


class RiskContext(Base):
    __tablename__ = "risk_context"
    __table_args__ = (
        CheckConstraint("exposure_level BETWEEN 1 AND 5", name="chk_exposure_level"),
        Index("risk_context_risk_id_idx", "risk_id"),
        Index("risk_context_context_id_idx", "context_id"),
    )

    risk_id = Column(String, ForeignKey("risk.risk_id", ondelete="CASCADE"), primary_key=True)
    context_id = Column(String, ForeignKey("energy_context.context_id", ondelete="CASCADE"), primary_key=True)
    exposure_level = Column(Integer, nullable=False)

    risk = relationship("Risk", back_populates="contexts")
    context = relationship("EnergyContext")


risk_card_index = Index("risk_card_gin_idx", Risk.card, postgresql_using="gin", postgresql_ops={"card": "jsonb_path_ops"})


@event.listens_for(Risk.__table__, "after_create")
def create_risk_update_trigger(target, connection, **kw):
    if connection.dialect.name != "postgresql":
        return
    connection.execute(
        text(
            """
            CREATE OR REPLACE FUNCTION set_updated_at()
            RETURNS TRIGGER AS $$
            BEGIN
                NEW.updated_at = NOW();
                RETURN NEW;
            END;
            $$ LANGUAGE plpgsql;

            CREATE TRIGGER trg_set_updated_at
            BEFORE UPDATE ON risk
            FOR EACH ROW
            EXECUTE PROCEDURE set_updated_at();
            """
        )
    )


@event.listens_for(Risk.__table__, "after_drop")
def drop_risk_update_trigger(target, connection, **kw):
    if connection.dialect.name != "postgresql":
        return
    connection.execute(
        text(
            """
            DROP TRIGGER IF EXISTS trg_set_updated_at ON risk;
            DROP FUNCTION IF EXISTS set_updated_at();
            """
        )
    )
