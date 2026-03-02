"""
Tests for the Echo Server API
"""

import sys
import os

# Add app directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'app'))

import pytest


@pytest.fixture
def client():
    """Create test client."""
    # Import here to avoid issues with module loading
    from fastapi.testclient import TestClient
    from main import app
    return TestClient(app)


def test_home_page(client):
    """Test that home page returns HTML."""
    response = client.get("/")
    assert response.status_code == 200
    assert "Echo Server" in response.text


def test_echo_endpoint(client):
    """Test the echo endpoint returns the message."""
    response = client.post("/echo", json={"message": "Hello, World!"})
    assert response.status_code == 200
    data = response.json()
    assert data["original"] == "Hello, World!"
    assert "Hello, World!" in data["echo"]


def test_echo_empty_message(client):
    """Test echo with empty message."""
    response = client.post("/echo", json={"message": ""})
    assert response.status_code == 200


def test_health_endpoint(client):
    """Test health check endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
