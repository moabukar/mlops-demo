from fastapi import FastAPI, File, UploadFile, HTTPException, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from ultralytics import YOLO
import uvicorn
from PIL import Image
import io
from typing import Dict

app = FastAPI(title="ML Web Service")
# Load the YOLO model at startup
model = YOLO('yolov8n.pt')

# Setup for Jinja2 templates
templates = Jinja2Templates(directory="templates")
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/", response_class=HTMLResponse)
async def root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request, "result": None})

@app.post("/detect")
async def detect_objects(request: Request, file: UploadFile = File(...)):
    # Validate file type
    if not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="File must be an image")
    
    try:
        # Read image file
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))
        
        # Perform prediction
        results = model(image)
        
        # Extract predictions
        predictions = []
        for result in results:
            boxes = result.boxes
            for box in boxes:
                pred = {
                    "class": result.names[int(box.cls[0])],
                    "confidence": float(box.conf[0]),
                    "bbox": box.xyxy[0].tolist()
                }
                predictions.append(pred)
        
        return templates.TemplateResponse(
            "index.html",
            {
                "request": request,
                "result": predictions,
                "filename": file.filename
            }
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
