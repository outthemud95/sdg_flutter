#!/bin/bash

set -e

PROJECT_ROOT="sdg-action-tracker"
FRONTEND_DIR="$PROJECT_ROOT/sdg_action_tracker_app"  # Flutter app directory
BACKEND_DIR="$PROJECT_ROOT/backend"
SHARED_DIR="$BACKEND_DIR/shared"
DATA_DIR="$PROJECT_ROOT/data"

echo "Updating project structure..."

# Frontend Setup (Flutter) - Skip if exists
if [ ! -d "$FRONTEND_DIR" ]; then
  echo "Creating Flutter frontend directory..."
  flutter create "$FRONTEND_DIR"
else
  echo "Skipping Flutter frontend directory creation: Already exists."
fi

# No need to reinstall Flutter dependencies or create frontend components/tests again.
# We will assume they are already there from the previous run of the script.

# Backend Setup (Flask) - Skip existing services and add new ones
cd "$BACKEND_DIR"
for service in auth user action progress knowledge blockchain rag api-gateway; do
    if [ ! -d "$service-service" ]; then 
        echo "Creating backend service: $service-service"
        mkdir -p "$service-service"  
        cd "$service-service"
        mkdir tests

        # Create Base Files
        touch app.py requirements.txt .env config.py
        echo "venv/" >> .gitignore
        echo "__pycache__/" >> .gitignore
    else
        echo "Skipping existing service: $service-service"
    fi
done

# Create Shared Backend Modules (only if missing)
if [ ! -d "$SHARED_DIR" ]; then
  echo "Creating shared backend modules directory..."
  mkdir -p "$SHARED_DIR"
else
  echo "Skipping shared modules directory creation: Already exists."
fi
touch "$SHARED_DIR/database.py" "$SHARED_DIR/utils.py" "$SHARED_DIR/errors.py" "$SHARED_DIR/middleware.py"

# Create Docker Compose file (only if missing)
if [ ! -f "$PROJECT_ROOT/docker-compose.yml" ]; then
    touch "$PROJECT_ROOT/docker-compose.yml"
else
  echo "Skipping Docker Compose file creation: Already exists."
fi

echo "Project structure updated successfully!"
