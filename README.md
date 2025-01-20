# MediaFlow Proxy Deployment on Heroku

## Overview
MediaFlow Proxy allows you to bypass single IP restrictions of debrid services like Real-Debrid and Torbox, enabling streaming across multiple devices using a single debrid account. This guide explains how to deploy it on Heroku using Docker.

## Prerequisites
- [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) installed
- Docker installed and running
- A Heroku account
- A Real-Debrid/Torbox account (optional for streaming)

## Deployment Steps

### Step 1: Clone the Repository
```sh
 git clone https://github.com/mhdzumair/mediaflow-proxy.git
 cd mediaflow-proxy
```

### Step 2: Create a Dockerfile
Create a new `Dockerfile` in the project root with the following content:
```dockerfile
# Use a lightweight Python base image
FROM python:3.12-slim

# Set the working directory
WORKDIR /app

# Install Poetry
RUN pip install --no-cache-dir poetry

# Copy the project files
COPY . .

# Install project dependencies with Poetry
RUN poetry config virtualenvs.create false && poetry install --no-interaction --no-ansi

# Expose the port for the application (Heroku will map this port)
EXPOSE 8000

# Run the application
CMD poetry run gunicorn mediaflow_proxy.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:$PORT --timeout 120 --max-requests 500 --max-requests-jitter 200 --access-logfile - --error-logfile - --log-level info
```

### Step 3: Modify `main.py`
Edit `main.py` to dynamically fetch the port number from the environment:
```python
import os
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from importlib import resources

app = FastAPI()

# Serve static files
static_path = resources.files("mediaflow_proxy").joinpath("static")
app.mount("/", StaticFiles(directory=str(static_path), html=True), name="static")

def run():
    import uvicorn
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port, log_level="info", workers=3)

if __name__ == "__main__":
    run()
```

### Step 4: Build the Docker Image
```sh
docker build --platform linux/amd64 -t registry.heroku.com/my-mediaflow-app/web .
```

### Step 5: Push the Docker Image to Heroku
```sh
docker push registry.heroku.com/my-mediaflow-app/web
```

### Step 6: Release the Application
```sh
heroku container:release web -a my-mediaflow-app
```

### Step 7: Verify Deployment
```sh
heroku open -a my-mediaflow-app
```

### Step 8: Check Logs (If Needed)
```sh
heroku logs --tail -a my-mediaflow-app
```

### Step 9: Configure Environment Variables
Login to the Heroku dashboard, navigate to **Settings → Config Vars**, and add:
- **Key:** `API_PASSWORD`  
- **Value:** `<your-password>`

## Usage
Once deployed, the MediaFlow Proxy can be used with **MediaFusion AIO Streams** package:
1. Go to: [MediaFusion Config](https://aiostreams.elfhosted.com/configure)
2. Select all default options for Addons, Torrentio, and Comet.
3. Check **MediaFlow** and provide the Heroku app URL along with the password in the extension config.
4. Generate the manifest and use it with **Stremio** for streaming.

## Benefits
- **Bypass single IP restrictions** of debrid services.
- **Stream from multiple devices/screens simultaneously** using the same debrid account.
- **Easy deployment** using Docker and Heroku.

## Disclaimer
This project is for **educational purposes only** and must not be used for commercial or illegal activities. The author holds no liability for any misuse violating service provider policies.
