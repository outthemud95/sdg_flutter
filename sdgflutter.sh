#!/bin/bash

set -e 

PROJECT_ROOT="sdg-action-tracker"
FRONTEND_DIR="$PROJECT_ROOT/sdg_action_tracker_app"  # Flutter app directory
BACKEND_DIR="$PROJECT_ROOT/backend"
SHARED_DIR="$BACKEND_DIR/shared"
DATA_DIR="$PROJECT_ROOT/data"

echo "Creating project structure..."

mkdir -p "$PROJECT_ROOT" "$BACKEND_DIR" "$DATA_DIR"
cd "$PROJECT_ROOT"

# Frontend Setup (Flutter)
if [ ! -d "$FRONTEND_DIR" ]; then
  echo "Installing Flutter..."

  # Install Flutter (replace with latest version as needed)
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
  export PATH="$PWD/flutter/bin:$PATH"  # Add Flutter to PATH

  echo "Creating Flutter frontend directory..."
  flutter create "$FRONTEND_DIR"
  
else
  echo "Skipping Flutter frontend directory creation: Already exists."
fi

# Install Flutter Dependencies
cd "$FRONTEND_DIR"
flutter pub add http provider flutter_svg charts_flutter flutter_localizations google_sign_in googleapis hive hive_flutter # Added hive packages
flutter pub add --dev flutter_test # for testing
#Add other Flutter Dependencies Here

# Create Frontend Directories, Components, and Tests
cd lib
mkdir -p components/{common,auth,dashboard,knowledge_base,user_profile,social_share,gamification,policy_advocacy} services models
for component in common auth dashboard knowledge_base user_profile social_share gamification policy-advocacy; do
    mkdir -p components/$component
    touch components/$component/$component.dart
done

touch services/api.dart services/hive_service.dart models/user.dart models/action_plan.dart main.dart

# Backend Setup (Flask)
cd ../..  # Navigate back to the project root 
cd "$BACKEND_DIR" # Change to the backend directory
for service in auth user action progress knowledge blockchain rag api-gateway; do # Added rag-service and api-gateway
    if [ ! -d "$service-service" ]; then 
        echo "Creating backend service: $service-service"
        mkdir -p "$service-service"  
        cd "$service-service"
        mkdir tests

        # Create Base Files
        touch app.py requirements.txt .env config.py
        echo "venv/" >> .gitignore
        echo "__pycache__/" >> .gitignore

        # Install and Freeze Base Dependencies
        python3 -m venv venv
        source venv/bin/activate
        pip install Flask Flask-SQLAlchemy Flask-Migrate python-dotenv
        pip freeze > requirements.txt 

        # Service-Specific Dependencies and File Creation
        case "$service" in
            auth)
                pip install firebase-admin
                pip freeze > requirements.txt
                touch tests/test_auth_service.py  # Initial test file
                ;;
            blockchain)
                pip install web3
                pip freeze > requirements.txt
                touch tests/test_blockchain_service.py
                mkdir contracts
                touch contracts/SDGTToken.sol
                ;;
            knowledge)
                pip install requests
                pip freeze > requirements.txt
                touch tests/test_knowledge_service.py
                ;;
            rag)
                pip install langchain google-cloud-aiplatform sentence-transformers tiktoken
                pip freeze > requirements.txt
                touch tests/test_rag_service.py
                ;;
            api-gateway)
                pip install Flask-RESTX
                pip freeze > requirements.txt
                ;;
            *)
                touch tests/test_${service}_service.py  
                ;;
        esac

        deactivate  
        cd .. # Navigate back to the backend directory
    else
        echo "Skipping existing service: $service-service"
    fi
done


# Create Shared Backend Modules AFTER the loop finishes 
mkdir -p "$SHARED_DIR"
touch "$SHARED_DIR/database.py" "$SHARED_DIR/utils.py" "$SHARED_DIR/errors.py" "$SHARED_DIR/middleware.py"
cd "$SHARED_DIR"
# Install dependencies for shared modules
python3 -m venv venv
source venv/bin/activate
pip install google-cloud-firestore
pip freeze > requirements.txt

# Create Docker Compose file
touch "$PROJECT_ROOT/docker-compose.yml"

echo "Project structure and base files created successfully!"
