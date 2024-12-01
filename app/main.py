from fastapi import FastAPI, File, UploadFile, HTTPException
from ultralytics import YOLO
import uvicorn
from PIL import Image
import io
from typing import List, Dict

app = FastAPI(title="ML Web Service")
# Load the YOLO model at startup
model = YOLO('yolov8n.pt')

@app.get("/")
async def root():
    return {"status": "ok", "message": "ML Web Service is running"}

@app.post("/detect")
async def detect_objects(file: UploadFile = File(...)) -> Dict:
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
        
        return {
            "filename": file.filename,
            "predictions": predictions
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)