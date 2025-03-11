#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check required tools
check_requirements() {
    print_message $YELLOW "Checking requirements..."
    
    local requirements=("node" "npm" "docker" "docker-compose")
    local missing=()
    
    for cmd in "${requirements[@]}"; do
        if ! command_exists "$cmd"; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        print_message $RED "Missing required tools: ${missing[*]}"
        print_message $RED "Please install them before continuing."
        exit 1
    fi
    
    print_message $GREEN "All requirements satisfied!"
}

# Install dependencies
install_dependencies() {
    print_message $YELLOW "Installing dependencies..."
    
    # Backend dependencies
    cd backend
    npm install
    cd ..
    
    # Frontend dependencies
    cd frontend
    npm install
    cd ..
    
    print_message $GREEN "Dependencies installed successfully!"
}

# Run development servers
dev() {
    print_message $YELLOW "Starting development servers..."
    
    # Start backend
    cd backend
    npm run dev &
    BACKEND_PID=$!
    cd ..
    
    # Start frontend
    cd frontend
    npm start &
    FRONTEND_PID=$!
    cd ..
    
    # Wait for both processes
    wait $BACKEND_PID $FRONTEND_PID
}

# Build for production
build() {
    print_message $YELLOW "Building for production..."
    
    # Build backend
    cd backend
    npm run build
    cd ..
    
    # Build frontend
    cd frontend
    npm run build
    cd ..
    
    print_message $GREEN "Build completed successfully!"
}

# Run tests
test() {
    print_message $YELLOW "Running tests..."
    
    # Backend tests
    cd backend
    npm test
    cd ..
    
    # Frontend tests
    cd frontend
    npm test
    cd ..
    
    print_message $GREEN "Tests completed!"
}

# Docker commands
docker_up() {
    print_message $YELLOW "Starting Docker containers..."
    docker-compose up -d
    print_message $GREEN "Docker containers started successfully!"
}

docker_down() {
    print_message $YELLOW "Stopping Docker containers..."
    docker-compose down
    print_message $GREEN "Docker containers stopped successfully!"
}

docker_build() {
    print_message $YELLOW "Building Docker images..."
    docker-compose build
    print_message $GREEN "Docker images built successfully!"
}

docker_logs() {
    print_message $YELLOW "Showing Docker logs..."
    docker-compose logs -f
}

# Clean up
clean() {
    print_message $YELLOW "Cleaning up..."
    
    # Remove node_modules
    rm -rf backend/node_modules frontend/node_modules
    
    # Remove build directories
    rm -rf backend/dist frontend/build
    
    # Remove logs
    rm -rf backend/logs/*
    
    print_message $GREEN "Clean up completed!"
}

# Show help
show_help() {
    echo "Usage: ./dev.sh [command]"
    echo ""
    echo "Commands:"
    echo "  check     - Check if all required tools are installed"
    echo "  install   - Install all dependencies"
    echo "  dev       - Start development servers"
    echo "  build     - Build for production"
    echo "  test      - Run all tests"
    echo "  docker-up - Start Docker containers"
    echo "  docker-down - Stop Docker containers"
    echo "  docker-build - Build Docker images"
    echo "  docker-logs - Show Docker logs"
    echo "  clean     - Clean up build files and dependencies"
    echo "  help      - Show this help message"
}

# Main script
case "$1" in
    "check")
        check_requirements
        ;;
    "install")
        check_requirements
        install_dependencies
        ;;
    "dev")
        check_requirements
        dev
        ;;
    "build")
        check_requirements
        build
        ;;
    "test")
        check_requirements
        test
        ;;
    "docker-up")
        check_requirements
        docker_up
        ;;
    "docker-down")
        check_requirements
        docker_down
        ;;
    "docker-build")
        check_requirements
        docker_build
        ;;
    "docker-logs")
        check_requirements
        docker_logs
        ;;
    "clean")
        clean
        ;;
    "help"|"")
        show_help
        ;;
    *)
        print_message $RED "Unknown command: $1"
        show_help
        exit 1
        ;;
esac

exit 0
