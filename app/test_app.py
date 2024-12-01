from fastapi.testclient import TestClient
from main import app
import os

client = TestClient(app)

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"

def test_detect_invalid_file():
    files = {"file": ("test.txt", "some text content", "text/plain")}
    response = client.post("/detect", files=files)
    assert response.status_code == 400

def test_detect_valid_image():
    # Assuming you have a test image in a tests/data directory
    test_image_path = "tests/data/test_image.jpg"
    if os.path.exists(test_image_path):
        with open(test_image_path, "rb") as f:
            files = {"file": ("test_image.jpg", f, "image/jpeg")}
            response = client.post("/detect", files=files)
            assert response.status_code == 200
            assert "predictions" in response.json()