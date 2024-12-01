from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_predict():
    with open("test_image.jpg", "rb") as f:
        response = client.post("/predict/", files={"file": ("test_image.jpg", f, "image/jpeg")})
        assert response.status_code == 200
