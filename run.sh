#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="wowonder"
COMPOSE_FILE="docker-compose.yml"

# Global variable for docker compose command type
DOCKER_COMPOSE_TYPE=""

# Function to run docker compose command
docker_compose_cmd() {
    if [ "$DOCKER_COMPOSE_TYPE" = "standalone" ]; then
        docker-compose "$@"
    elif [ "$DOCKER_COMPOSE_TYPE" = "plugin" ]; then
        docker compose "$@"
    else
        print_error "Docker Compose not detected"
        exit 1
    fi
}

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect docker compose command
detect_docker_compose() {
    # Prioritize docker compose (plugin) over docker-compose (standalone)
    if docker compose version >/dev/null 2>&1; then
        DOCKER_COMPOSE_TYPE="plugin"
    elif command -v docker-compose >/dev/null 2>&1; then
        DOCKER_COMPOSE_TYPE="standalone"
    else
        DOCKER_COMPOSE_TYPE=""
    fi
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Detect docker compose command
    detect_docker_compose
    
    # Check for docker-compose or docker compose
    if [ -z "$DOCKER_COMPOSE_TYPE" ]; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        print_info "You can use either 'docker-compose' (standalone) or 'docker compose' (plugin)"
        exit 1
    fi
    
    print_success "All prerequisites are met."
    if [ "$DOCKER_COMPOSE_TYPE" = "standalone" ]; then
        print_info "Using: docker-compose (standalone)"
    else
        print_info "Using: docker compose (plugin)"
    fi
}

# Function to check if containers are running
check_containers() {
    if docker_compose_cmd ps 2>/dev/null | grep -q "Up"; then
        return 0
    else
        return 1
    fi
}

# Function to start services
start_services() {
    print_info "Starting services..."
    
    if check_containers; then
        print_warning "Containers are already running."
        return
    fi
    
    # Create necessary directories
    mkdir -p docker/db_data
    mkdir -p docker/nginx/logs
    
    # Start services
    docker_compose_cmd up -d
    
    if [ $? -eq 0 ]; then
        print_success "Services started successfully!"
        print_info "Waiting for services to be ready..."
        sleep 5
        show_status
    else
        print_error "Failed to start services."
        exit 1
    fi
}

# Function to stop services
stop_services() {
    print_info "Stopping services..."
    docker_compose_cmd down
    print_success "Services stopped."
}

# Function to restart services
restart_services() {
    print_info "Restarting services..."
    stop_services
    sleep 2
    start_services
}

# Function to build services
build_services() {
    print_info "Building services..."
    docker_compose_cmd build --no-cache
    
    if [ $? -eq 0 ]; then
        print_success "Services built successfully!"
    else
        print_error "Failed to build services."
        exit 1
    fi
}

# Function to show logs
show_logs() {
    if [ -z "$1" ]; then
        print_info "Showing logs for all services..."
        docker_compose_cmd logs -f
    else
        print_info "Showing logs for service: $1"
        docker_compose_cmd logs -f "$1"
    fi
}

# Function to show status
show_status() {
    print_info "Service status:"
    echo ""
    docker_compose_cmd ps
    echo ""
    
    if check_containers; then
        print_info "Service URLs:"
        echo "  - Web: http://goivondautu.delitech.vn"
        echo "  - Database: localhost:3434"
        echo ""
        print_info "Container names:"
        docker_compose_cmd ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
    fi
}

# Function to clean up
clean_up() {
    print_warning "This will remove all containers, volumes, and networks."
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Cleaning up..."
        docker_compose_cmd down -v --remove-orphans
        print_success "Cleanup completed."
    else
        print_info "Cleanup cancelled."
    fi
}

# Function to execute command in container
exec_container() {
    if [ -z "$1" ]; then
        print_error "Please specify container name (php, nodejs, db, nginx)"
        exit 1
    fi
    
    print_info "Executing command in container: $1"
    docker_compose_cmd exec "$1" /bin/bash
}

# Function to show help
show_help() {
    echo "Usage: ./run.sh [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  start          Start all services"
    echo "  stop           Stop all services"
    echo "  restart        Restart all services"
    echo "  build          Build all services"
    echo "  logs [service] Show logs (optionally for specific service)"
    echo "  status         Show service status"
    echo "  exec <service> Execute command in container (php, nodejs, db, nginx)"
    echo "  clean          Remove all containers, volumes, and networks"
    echo "  help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./run.sh start"
    echo "  ./run.sh logs php"
    echo "  ./run.sh exec php"
    echo "  ./run.sh restart"
}

# Main script
main() {
    # Check prerequisites
    check_prerequisites
    
    # Parse command
    case "${1:-help}" in
        start)
            start_services
            ;;
        stop)
            stop_services
            ;;
        restart)
            restart_services
            ;;
        build)
            build_services
            ;;
        logs)
            show_logs "$2"
            ;;
        status)
            show_status
            ;;
        exec)
            exec_container "$2"
            ;;
        clean)
            clean_up
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"

