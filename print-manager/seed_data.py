from sqlalchemy.orm import Session
from database import SessionLocal, engine
import models

models.Base.metadata.create_all(bind=engine)

def seed_database():
    db = SessionLocal()
    
    existing_printers = db.query(models.Printer).count()
    if existing_printers > 0:
        print(f"Database already has {existing_printers} printers. Skipping seed.")
        db.close()
        return
    
    printers = [
        models.Printer(name="Printer-A", model="Stratasys F370", location="London Office", status="idle"),
        models.Printer(name="Printer-B", model="Fortus 450mc", location="Manchester Lab", status="printing"),
        models.Printer(name="Printer-C", model="J55 Prime", location="Birmingham Facility", status="idle"),
        models.Printer(name="Printer-D", model="F770", location="London Office", status="maintenance")
    ]
    
    for printer in printers:
        db.add(printer)
    
    db.commit()
    print(f"✅ Created {len(printers)} printers")
    
    db.refresh(printers[0])
    db.refresh(printers[1])
    db.refresh(printers[2])
    
    jobs = [
        models.Job(name="Bracket v3", file_name="bracket_v3.stl", printer_id=printers[0].id, status="completed"),
        models.Job(name="Housing Prototype", file_name="housing_proto.stl", printer_id=printers[1].id, status="printing"),
        models.Job(name="Test Calibration", file_name="calibration.stl", printer_id=printers[2].id, status="queued"),
        models.Job(name="Gear Assembly", file_name="gear_asm.stl", printer_id=printers[0].id, status="queued"),
        models.Job(name="Motor Mount v2", file_name="motor_mount_v2.stl", printer_id=printers[2].id, status="queued"),
    ]
    
    for job in jobs:
        db.add(job)
    
    db.commit()
    print(f"✅ Created {len(jobs)} jobs")
    db.close()
    print("\n✅ Database seeded successfully!")

if __name__ == "__main__":
    print("🌱 Seeding database...")
    seed_database()

