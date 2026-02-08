from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base

class Printer(Base):
    __tablename__ = "printers"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    model = Column(String(100))
    location = Column(String(100))
    status = Column(String(20), default='idle')
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    jobs = relationship("Job", back_populates="printer")
    
    def __repr__(self):
        return f"<Printer(name='{self.name}', status='{self.status}')>"

class Job(Base):
    __tablename__ = "jobs"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200), nullable=False)
    file_name = Column(String(200))
    printer_id = Column(Integer, ForeignKey('printers.id'))
    status = Column(String(20), default='queued')
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    started_at = Column(DateTime(timezone=True), nullable=True)
    completed_at = Column(DateTime(timezone=True), nullable=True)
    
    printer = relationship("Printer", back_populates="jobs")
    
    def __repr__(self):
        return f"<Job(name='{self.name}', status='{self.status}')>"

