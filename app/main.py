from fastapi import FastAPI, File, UploadFile
from ultralytics import YOLO
from PIL import Image
import io

app = FastAPI()

# Load YOLOv8 model
model = YOLO("yolov8n.pt")  # Change model file as needed

@app.post("/predict/")
async def predict(file: UploadFile = File(...)):
    try:
        # Load the image
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))
        
        # Perform detection
        results = model(image)
        
        # Parse the results
        detections = [
            {"class": result["class"], "confidence": result["confidence"]}
            for result in results[0].boxes.xyxy.cpu().numpy()
        ]
        return {"detections": detections}
    except Exception as e:
        return {"error": str(e)}
