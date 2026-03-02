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


def test_sql_injection_blocked(client):
    """Test that SQL injection attempts are blocked."""
    # DROP TABLE attack
    response = client.post("/echo", json={"message": "Hello DROP TABLE bogus; --"})
    assert response.status_code == 400
    assert "SQL injection" in response.json()["detail"]


def test_sql_injection_select_blocked(client):
    """Test SELECT injection is blocked."""
    response = client.post("/echo", json={"message": "'; SELECT * FROM users; --"})
    assert response.status_code == 400


def test_sql_injection_union_blocked(client):
    """Test UNION injection is blocked."""
    response = client.post("/echo", json={"message": "1 UNION SELECT password FROM users"})
    assert response.status_code == 400


def test_sql_injection_or_1_equals_1(client):
    """Test OR 1=1 injection is blocked."""
    response = client.post("/echo", json={"message": "admin' OR 1=1 --"})
    assert response.status_code == 400


def test_normal_message_allowed(client):
    """Test that normal messages still work."""
    response = client.post("/echo", json={"message": "Hello, this is a normal message!"})
    assert response.status_code == 200


def test_xss_sanitized(client):
    """Test that XSS attempts are sanitized."""
    response = client.post("/echo", json={"message": "<script>alert('xss')</script>"})
    assert response.status_code == 200
    data = response.json()
    # HTML should be escaped
    assert "<script>" not in data["original"]
    assert "&lt;script&gt;" in data["original"]