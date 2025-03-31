#!/bin/bash

set -e  # Exit immediately if any command fails

# Color definitions
GREEN='\e[32m'
YELLOW='\e[33m'
RED='\e[31m'
CYAN='\e[36m'
BLUE='\e[34m'
MAGENTA='\e[35m'
NC='\e[0m'  # No Color
RESET='\e[0m'

# Script save path
SCRIPT_PATH="$HOME/naptha.sh"

# Display header
display_header() {
    clear
    echo -e "${CYAN}"
    echo -e "    ${RED}██╗  ██╗ █████╗ ███████╗ █████╗ ███╗   ██╗${NC}"
    echo -e "    ${GREEN}██║  ██║██╔══██╗██╔════╝██╔══██╗████╗  ██║${NC}"
    echo -e "    ${BLUE}███████║███████║███████╗███████║██╔██╗ ██║${NC}"
    echo -e "    ${YELLOW}██╔══██║██╔══██║╚════██║██╔══██║██║╚██╗██║${NC}"
    echo -e "    ${MAGENTA}██║  ██║██║  ██║███████║██║  ██║██║ ╚████║${NC}"
    echo -e "    ${CYAN}╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝${NC}"
    echo -e "${BLUE}=======================================================${NC}"
    echo -e "${GREEN}            🚀 Naptha Node Management 🚀${NC}"
    echo -e "${BLUE}=======================================================${NC}"
    echo -e "${CYAN}    🌐  Telegram: @CryptoAirdropHindi${NC}"
    echo -e "${CYAN}    📺  YouTube:  @CryptoAirdropHindi6${NC}"
    echo -e "${CYAN}    💻  GitHub:   github.com/CryptoAirdropHindi${NC}"
    echo -e "${BLUE}=======================================================${NC}"
    echo -e "${YELLOW}       The most advanced node management system${NC}"
    echo "${BLUE}============================================================${NC}"
    echo "To exit the script, press Ctrl + C"
    echo "Please select an operation:"
    echo "1. Install Naptha Node"
    echo "2. Remove Naptha Node"  
    echo "3. View PRIVATE_KEY"   
    echo "4. View Logs" 
    echo "5. Exit Script"
}

# Main menu function
main_menu() {
    while true; do
        # Display header and prompt for option selection
        display_header
        read -p "Enter option number: " option

        case $option in
            1)
                install_naptha_node
                ;;
            2)
                remove_naptha_node  # Call function to remove node
                ;;
            3)
                view_private_key  # Call function to view PRIVATE_KEY
                ;;
            4)
                view_logs  # Call function to view logs
                ;;
            5)
                echo "Exiting script..."
                exit 0  # Exit script
                ;;
            *)
                echo "Invalid option, please try again..."
                sleep 2
                ;;
        esac
    done
}

# Function to remove Naptha node
function remove_naptha_node() {
    echo "Removing Naptha Node..."

    # Stop and remove Docker containers
    echo "Stopping and removing Docker containers..."
    docker stop node-pgvector node-ollama node-rabbitmq litellm node-app 2>/dev/null
    docker rm node-pgvector node-ollama node-rabbitmq litellm node-app 2>/dev/null

    # Execute docker-ctl.sh down
    if [ -f "docker-ctl.sh" ]; then
        echo "Executing docker-ctl.sh down..."
        bash docker-ctl.sh down
    else
        echo "docker-ctl.sh file not found, skipping"
    fi

    echo "Naptha Node removed"

    # Prompt to press any key to return to menu
    read -n 1 -s -r -p "Press any key to return to menu..."
    main_menu
}

# Function to view PRIVATE_KEY
function view_private_key() {
    echo "Viewing PRIVATE_KEY..."
    # Open .pem files in directory
    for pem_file in /root/node/*.pem; do
        if [ -f "$pem_file" ]; then
            echo "Opening file: $pem_file"
            cat "$pem_file"  # Display file content
            echo "-----------------------------"
        else
            echo "No .pem files found"
        fi
    done
    # Prompt to press any key to return to menu
    read -n 1 -s -r -p "Press any key to return to menu..."
    main_menu
}

# Create virtual environment and install dependencies
function create_virtualenv() {
    echo "Creating Python virtual environment and installing dependencies..."
    
    # Create virtual environment
    python3 -m venv .venv
    
    # Activate environment
    source .venv/bin/activate
    
    # Upgrade pip
    pip install --upgrade pip
    
    # Install required dependencies
    pip install docker requests
    
    echo "Virtual environment created and dependencies installed!"
}

# Function to install Naptha node
function install_naptha_node() {
    echo "Installing Naptha Node..."

    # Check if Docker is installed
    if ! command -v docker &> /dev/null
    then
        echo "Docker not found, installing Docker..."
        # Install Docker
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce
        sudo systemctl start docker
        sudo systemctl enable docker
        echo "Docker installed"
    else
        echo "Docker already installed"
    fi

    # Check if Docker Compose is installed
    if ! command -v docker-compose &> /dev/null
    then
        echo "Docker Compose not found, installing..."
        # Install Docker Compose
        sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        echo "Docker Compose installed"
    else
        echo "Docker Compose already installed"
    fi

    # Check if Python3 and pip are installed
    if ! command -v python3 &> /dev/null
    then
        echo "Python3 not found, installing..."
        sudo apt-get install -y python3
    else
        echo "Python3 already installed"
    fi

    if ! command -v pip3 &> /dev/null
    then
        echo "pip3 not found, installing..."
        sudo apt-get install -y python3-pip
    else
        echo "pip3 already installed"
    fi

    # Check and install python3-venv
    if ! dpkg -l | grep -q python3-venv; then
        echo "python3-venv not found, installing..."
        sudo apt-get install -y python3-venv
    else
        echo "python3-venv already installed"
    fi

    # Check Poetry version
    if command -v poetry &> /dev/null
    then
        POETRY_VERSION=$(poetry --version | awk '{print \\$2}')
        if [[ $(echo "$POETRY_VERSION < 1.2" | bc -l) -eq 1 ]]; then
            echo "Poetry version lower than 1.2, updating..."
            curl -sSL https://install.python-poetry.org | python3 -
        else
            echo "Poetry already installed, version $POETRY_VERSION"
        fi
    else
        echo "Poetry not found, installing..."
        curl -sSL https://install.python-poetry.org | python3 -
    fi

    # Remove existing node directory if present
    if [ -d "node" ]; then
        echo "Target directory 'node' exists, removing..."
        rm -rf node
    fi

    # Clone Git repository
    echo "Cloning Git repository..."
    git clone https://github.com/NapthaAI/node.git

    # Enter directory
    cd node

    # Create virtual environment and install dependencies
    create_virtualenv

    # Copy .env.example to .env
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "Copied .env.example to .env"

        # Modify .env file
        sed -i 's/LAUNCH_DOCKER=false/LAUNCH_DOCKER=true/' .env
        sed -i 's|HF_HOME=/home/<youruser>/.cache/huggingface|HF_HOME=/root/.cache/huggingface|' .env
        echo "Set LAUNCH_DOCKER to true in .env"
        echo "Set HF_HOME to /root/.cache/huggingface in .env"
    else
        echo ".env.example not found, cannot create .env"
    fi

    # Execute launch.sh
    if [ -f launch.sh ]; then
        echo "Executing launch.sh..."
        bash launch.sh
    else
        echo "launch.sh not found"
    fi

    # Display script path
    echo "Script saved at: $SCRIPT_PATH"

    # Prompt to press any key to return to menu
    read -n 1 -s -r -p "Press any key to return to menu..."
    main_menu
}

# Function to view logs
function view_logs() {
    echo "Viewing logs..."
    
    # Enter node directory
    if cd node; then
        # View logs using docker-compose, show last 300 lines and follow
        docker-compose logs -f --tail=300
    else
        echo "Cannot enter node directory, make sure it exists"
    fi

    # Prompt to press any key to return to menu
    read -n 1 -s -r -p "Press any key to return to menu..."
    main_menu
}

# Call main menu
main_menu
