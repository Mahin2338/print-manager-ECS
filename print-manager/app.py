

from fastapi import FastAPI
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os
import models
import seed_data  



DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)



models.Base.metadata.create_all(bind=engine)



try:
    db = SessionLocal()

    if db.query(models.Printer).count() == 0:
        print("Database empty, running seed...")
        seed_data.seed_database()  
        print("Seeding complete!")
    else:
        print("Data already exists, skipping seed")
    db.close()
except Exception as e:
    print(f"Seed error: {e}")

app = FastAPI()



from fastapi import FastAPI, Request, Form, HTTPException
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session
from datetime import datetime
import models
from database import engine, get_db


# Create database tables
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="3D Print Manager")

# Mount static files and templates
templates = Jinja2Templates(directory="templates")

@app.get("/health")
def health_check():
    """Health check endpoint for ALB"""
    return {"status": "healthy"}

@app.get("/", response_class=HTMLResponse)
def dashboard(request: Request):
    """Main dashboard showing printers and recent jobs"""
    db = next(get_db())
    
    printers = db.query(models.Printer).all()
    recent_jobs = db.query(models.Job).order_by(models.Job.created_at.desc()).limit(10).all()
    
    # Calculate stats
    total_printers = len(printers)
    active_printers = len([p for p in printers if p.status == 'printing'])
    total_jobs = db.query(models.Job).count()
    queued_jobs = db.query(models.Job).filter(models.Job.status == 'queued').count()
    
    return templates.TemplateResponse("index.html", {
        "request": request,
        "printers": printers,
        "recent_jobs": recent_jobs,
        "stats": {
            "total_printers": total_printers,
            "active_printers": active_printers,
            "total_jobs": total_jobs,
            "queued_jobs": queued_jobs
        }
    })

@app.get("/jobs", response_class=HTMLResponse)
def list_jobs(request: Request):
    """List all print jobs"""
    db = next(get_db())
    jobs = db.query(models.Job).order_by(models.Job.created_at.desc()).all()
    
    return templates.TemplateResponse("jobs.html", {
        "request": request,
        "jobs": jobs
    })

@app.get("/jobs/create", response_class=HTMLResponse)
def create_job_form(request: Request):
    """Show create job form"""
    db = next(get_db())
    printers = db.query(models.Printer).filter(models.Printer.status == 'idle').all()
    
    return templates.TemplateResponse("create_job.html", {
        "request": request,
        "printers": printers
    })

@app.post("/jobs/create")
def create_job(
    name: str = Form(...),
    file_name: str = Form(...),
    printer_id: int = Form(...)
):
    """Create a new print job"""
    db = next(get_db())
    
    # Check if printer exists and is available
    printer = db.query(models.Printer).filter(models.Printer.id == printer_id).first()
    if not printer:
        raise HTTPException(status_code=404, detail="Printer not found")
    
    # Create new job
    new_job = models.Job(
        name=name,
        file_name=file_name,
        printer_id=printer_id,
        status='queued'
    )
    
    db.add(new_job)
    db.commit()
    
    return RedirectResponse(url="/jobs", status_code=303)

@app.get("/printers", response_class=HTMLResponse)
def list_printers(request: Request):
    """List all printers"""
    db = next(get_db())
    printers = db.query(models.Printer).all()
    
    return templates.TemplateResponse("printers.html", {
        "request": request,
        "printers": printers
    })

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)

