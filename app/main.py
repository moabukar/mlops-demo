from fastapi import FastAPI, File, UploadFile, HTTPException
from ultralytics import YOLO
import uvicorn
from PIL import Image
import io
from typing import List, Dict
import logging
from decouple import config

# Set up logging
logging.basicConfig(level=logging.INFO)

# Configuration
MODEL_PATH = config("MODEL_PATH", default="yolov8n.pt")
PORT = config("PORT", default=8000, cast=int)

app = FastAPI(title="ML Web Service")

# Load YOLO model
try:
    logging.info(f"Loading YOLO model from {MODEL_PATH}...")
    model = YOLO(MODEL_PATH)
    logging.info("YOLO model loaded successfully.")
except Exception as e:
    logging.error(f"Failed to load YOLO model: {str(e)}")
    raise RuntimeError("YOLO model loading failed.")

# Helper function to parse predictions
def parse_predictions(results, threshold: float = 0.5) -> List[Dict]:
    predictions = []
    for result in results:
        boxes = result.boxes
        for box in boxes:
            if float(box.conf[0]) >= threshold:
                predictions.append({
                    "class": result.names[int(box.cls[0])],
                    "confidence": float(box.conf[0]),
                    "bbox": box.xyxy[0].tolist()
                })
    return predictions

@app.get("/")
async def root():
    return {"status": "ok", "message": "ML Web Service is running"}

@app.post("/detect")
async def detect_objects(file: UploadFile = File(...)) -> Dict:
    # Validate file type
    if not file.content_type.startswith("image/"):
        logging.warning(f"Invalid file type: {file.content_type}")
        raise HTTPException(status_code=400, detail="File must be an image")

    try:
        # Read image file
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))

        # Perform prediction
        logging.info(f"Running prediction on file: {file.filename}")
        results = model(image)

        # Parse predictions
        predictions = parse_predictions(results)

        logging.info(f"Prediction complete for file: {file.filename}")
        return {
            "filename": file.filename,
            "predictions": predictions
        }

    except Exception as e:
        logging.error(f"Error during object detection: {str(e)}")
        raise HTTPException(status_code=500, detail="An error occurred during object detection")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=PORT)
