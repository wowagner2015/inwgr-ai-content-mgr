#!/bin/bash

# Script to automate the creation of a new project, GitHub repository, and Firebase setup
# Usage: ./setup_project.sh -d /path/to/projects -u github_username -p project_name
# Example: ./setup_project.sh -d /Users/wowagner/Documents/Projects -u wowagner2015 -p inwgr-ai-content-mgr

# Default values
DEFAULT_DIR="/Users/wowagner/Documents/Projects"
DEFAULT_GITHUB_USER="wowagner2015"

# Function to display help message
display_help() {
    echo "Usage: $0 -d /path/to/projects -u github_username -p project_name"
    echo
    echo "   -d, --directory   Specify the directory where the project will be created."
    echo "   -u, --user        Specify the GitHub username."
    echo "   -p, --project     Specify the project name (must be Firebase/GitHub compatible)."
    echo "   -h, --help        Display this help message."
    echo
    exit 1
}

# Function to validate Firebase project name
validate_project_name() {
    local name="$1"
    if [[ ${#name} -le 30 && "$name" =~ ^[a-z0-9-]+$ ]]; then
        echo "Valid project name."
        return 0
    else
        echo "Invalid project name. Ensure it is lowercase, contains only letters, numbers, and hyphens, and is no more than 30 characters."
        return 1
    fi
}

# Function to create the project directory, initialize Git, and create a GitHub repository
create_project() {
    local project_dir="$1"
    local github_user="$2"
    local project_name="$3"

    # Create project directory
    mkdir -p "$project_dir/$project_name"
    cd "$project_dir/$project_name" || exit

    # Initialize Git
    git init

    # Create a README.md file
    touch README.md
    git add README.md
    git commit -m "Initial commit"

    # Create GitHub repository
    gh repo create "$github_user/$project_name" --public --source=. --remote=origin

    # Push to GitHub
    git push -u origin master
}

# Function to initialize Firebase in the project directory
initialize_firebase() {
    local project_name="$1"

    cd "$project_dir/$project_name" || exit
    firebase init hosting --project "$project_name"
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -d|--directory)
            project_dir="$2"
            shift 2
            ;;
        -u|--user)
            github_user="$2"
            shift 2
            ;;
        -p|--project)
            project_name="$2"
            shift 2
            ;;
        -h|--help)
            display_help
            ;;
        *)
            echo "Unknown parameter: $1"
            display_help
            ;;
    esac
done

# Set default values if not provided
project_dir="${project_dir:-$DEFAULT_DIR}"
github_user="${github_user:-$DEFAULT_GITHUB_USER}"

# Ensure all necessary parameters are provided
if [[ -z "$project_name" ]]; then
    echo "Error: Project name is required."
    display_help
fi

# Validate project name
validate_project_name "$project_name" || exit 1

# Create project, GitHub repository, and Firebase setup
create_project "$project_dir" "$github_user" "$project_name"
initialize_firebase "$project_name"

echo "Project setup complete! Your project is ready at $project_dir/$project_name and on GitHub at https://github.com/$github_user/$project_name."
