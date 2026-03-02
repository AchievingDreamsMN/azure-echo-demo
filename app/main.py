"""
Simple Echo Web Server
Demonstrates a basic Python web application for Azure Container Apps deployment.
"""

from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import HTMLResponse
from pydantic import BaseModel, field_validator
import uvicorn
import os
import re
import html

ENVIRONMENT = os.getenv("ENVIRONMENT", "development")
PORT = int(os.getenv("PORT", "8080"))

# SQL injection patterns to detect and block
SQL_INJECTION_PATTERNS = [
    r"(\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|ALTER|CREATE|TRUNCATE)\b)",
    r"(--|#|/\*|\*/)",  # SQL comments
    r"(\bOR\b\s+\d+\s*=\s*\d+)",  # OR 1=1 patterns
    r"(\bAND\b\s+\d+\s*=\s*\d+)",  # AND 1=1 patterns
    r"(;\s*(SELECT|INSERT|UPDATE|DELETE|DROP))",  # Chained queries
    r"(\bEXEC\b|\bEXECUTE\b)",  # Execute commands
    r"(CHAR\s*\(|CONCAT\s*\()",  # String manipulation functions
    r"(\bWAITFOR\b|\bBENCHMARK\b)",  # Time-based injection
]


def detect_sql_injection(text: str) -> bool:
    """Check if text contains SQL injection patterns."""
    for pattern in SQL_INJECTION_PATTERNS:
        if re.search(pattern, text, re.IGNORECASE):
            return True
    return False


def sanitize_input(text: str) -> str:
    """Sanitize input to prevent injection attacks."""
    # HTML encode to prevent XSS
    sanitized = html.escape(text)
    return sanitized

app = FastAPI(
    title="Echo Server",
    description="A simple echo server that returns what you send it",
    version="1.0.0"
)


class EchoRequest(BaseModel):
    """Request model for echo endpoint."""
    message: str


class EchoResponse(BaseModel):
    """Response model for echo endpoint."""
    echo: str
    original: str


@app.get("/", response_class=HTMLResponse)
async def home():
    """Serve a simple HTML page with an input form."""
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Echo Server</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                max-width: 600px;
                margin: 50px auto;
                padding: 20px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
            }
            .container {
                background: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            }
            h1 { color: #333; text-align: center; }
            input[type="text"] {
                width: 100%;
                padding: 15px;
                font-size: 16px;
                border: 2px solid #ddd;
                border-radius: 5px;
                box-sizing: border-box;
                margin-bottom: 15px;
            }
            button {
                width: 100%;
                padding: 15px;
                font-size: 16px;
                background: #667eea;
                color: white;
                border: none;
                border-radius: 5px;
                cursor: pointer;
            }
            button:hover { background: #5a6fd6; }
            #result {
                margin-top: 20px;
                padding: 20px;
                background: #f5f5f5;
                border-radius: 5px;
                display: none;
            }
            .echo-text { 
                font-size: 24px; 
                color: #667eea;
                word-wrap: break-word;
            }
            .info {
                margin-top: 20px;
                padding: 15px;
                background: #e8f4f8;
                border-radius: 5px;
                font-size: 14px;
                color: #666;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🔊 Echo Server</h1>
            <p>Type something and it will be echoed back to you!</p>
            
            <input type="text" id="message" placeholder="Type your message here..." autofocus>
            <button onclick="sendEcho()">Echo!</button>
            
            <div id="result">
                <strong>Server echoed:</strong>
                <p class="echo-text" id="echoText"></p>
            </div>
            
            <div class="info">
                <strong>API Endpoints:</strong><br>
                • POST /echo - Send JSON {"message": "your text"}<br>
                • GET /health - Health check endpoint
            </div>
        </div>
        
        <script>
            async function sendEcho() {
                const message = document.getElementById('message').value;
                if (!message) return;
                
                const response = await fetch('/echo', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({message: message})
                });
                
                const data = await response.json();
                document.getElementById('echoText').textContent = data.echo;
                document.getElementById('result').style.display = 'block';
            }
            
            document.getElementById('message').addEventListener('keypress', function(e) {
                if (e.key === 'Enter') sendEcho();
            });
        </script>
    </body>
    </html>
    """


@app.post("/echo", response_model=EchoResponse)
async def echo(request: EchoRequest):
    """Echo back the message sent by the user with security validation."""
    # Check for SQL injection patterns
    if detect_sql_injection(request.message):
        raise HTTPException(
            status_code=400,
            detail="Potential SQL injection detected. Request blocked."
        )
    
    # Sanitize input
    sanitized_message = sanitize_input(request.message)
    
    return EchoResponse(
        echo=f"🔊 {sanitized_message}",
        original=sanitized_message
    )


@app.get("/health")
async def health():
    """Health check endpoint for container orchestration."""
    return {"status": "healthy", "service": "echo-server", "environment": ENVIRONMENT}


if __name__ == "__main__":
    print(f"Starting Echo Server on port {PORT} (environment: {ENVIRONMENT})")
    uvicorn.run(app, host="0.0.0.0", port=PORT)
