from fastapi.testclient import TestClient
from unittest.mock import MagicMock
from main import app, parse_predictions, model
import os

client = TestClient(app)

# Mock YOLO model for tests
def mock_predict(image):
    return [
        MagicMock(
            boxes=[
                MagicMock(cls=[0], conf=[0.95], xyxy=[[100, 200, 300, 400]]),
            ],
            names={0: "car"}
        )
    ]

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"

def test_detect_invalid_file():
    files = {"file": ("test.txt", "some text content", "text/plain")}
    response = client.post("/detect", files=files)
    assert response.status_code == 400
    assert response.json()["detail"] == "File must be an image"

def test_detect_valid_image():
    model.predict = MagicMock(side_effect=mock_predict)  # Mocking model predictions
    test_image_path = "tests/data/test_image.jpg"

    # Ensure test image exists
    if os.path.exists(test_image_path):
        with open(test_image_path, "rb") as f:
            files = {"file": ("test_image.jpg", f, "image/jpeg")}
            response = client.post("/detect", files=files)
            assert response.status_code == 200
            assert "predictions" in response.json()
            assert response.json()["predictions"][0]["class"] == "car"
            assert response.json()["predictions"][0]["confidence"] >= 0.5

def test_parse_predictions():
    # Mock results to simulate YOLO output
    mock_results = mock_predict(None)
    parsed_predictions = parse_predictions(mock_results, threshold=0.5)

    assert len(parsed_predictions) == 1
    assert parsed_predictions[0]["class"] == "car"
    assert parsed_predictions[0]["confidence"] >= 0.5
