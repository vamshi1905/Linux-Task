#!/bin/bash

show_help() {
  echo "Usage: internsctl <command> [options]"
  echo ""
  echo "Commands:"
  echo "  cpu getinfo           Get CPU information"
  echo "  memory getinfo        Get memory information"
  echo "  user create <username> Create a new user"
  echo "  user list             List all regular users"
  echo "  user list --sudo-only List users with sudo permissions"
  echo "  file getinfo <file>   Get information about a file"
  echo "    Options:"
  echo "      --size, -s         Print file size"
  echo "      --permissions, -p  Print file permissions"
  echo "      --owner, -o        Print file owner"
  echo "      --last-modified, -m Print last modified time"
  echo ""
}

show_version() {
  echo "internsctl v0.1.0"
}

get_cpu_info() {
  lscpu
}

get_memory_info() {
  free
}

create_user() {
  echo "Number of arguments: $#"
  echo "Username: $1"

  if [ -z "$1" ]; then
    echo "Error: Missing username. Usage: internsctl user create <username>"
  else
    sudo useradd -m "$1"
    echo "User '$1' created successfully."
  fi
}

list_users() {
  if [ "$1" = "--sudo-only" ]; then
    getent passwd | cut -d: -f1,3,7 | awk -F: '$2 >= 1000 {print $1}' | xargs groups | grep -E '\bsudo\b' | cut -d: -f1
  else
    getent passwd | cut -d: -f1
  fi
}

get_file_info() {
  local file="$1"
  local size=""
  local permissions=""
  local owner=""
  local last_modified=""

  if [ ! -e "$file" ]; then
    echo "Error: File '$file' not found."
    return
  fi

  size=$(stat -c %s "$file")

  case $2 in
    --size|-s)
      echo "$size"
      ;;
    --permissions|-p)
      permissions=$(stat -c %A "$file")
      echo "$permissions"
      ;;
    --owner|-o)
      owner=$(stat -c %U "$file")
      echo "$owner"
      ;;
    --last-modified|-m)
      last_modified=$(stat -c %y "$file")
      echo "$last_modified"
      ;;
    *)
      echo "Invalid option. Use --size, --permissions, --owner, or --last-modified."
      ;;
  esac
}

while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h)
      show_help
      exit 0
      ;;
    --version)
      show_version
      exit 0
      ;;
    cpu)
      shift
      case "$1" in
        getinfo)
          get_cpu_info
          exit 0
          ;;
        *)
          echo "Error: Invalid command. Use 'internsctl --help' for usage."
          exit 1
          ;;
      esac
      ;;
    memory)
      shift
      case "$1" in
        getinfo)
          get_memory_info
          exit 0
          ;;
        *)
          echo "Error: Invalid command. Use 'internsctl --help' for usage."
          exit 1
          ;;
      esac
      ;;
    user)
      shift
      case "$1" in
        create)
          shift
          create_user "$@"
          exit 0
          ;;
        list)
          shift
          list_users "$@"
          exit 0
          ;;
        *)
          echo "Error: Invalid command. Use 'internsctl --help' for usage."
          exit 1
          ;;
      esac
      ;;
    file)
      shift
      case "$1" in
        getinfo)
          shift
          get_file_info "$@"
          exit 0
          ;;
        *)
          echo "Error: Invalid command. Use 'internsctl --help' for usage."
          exit 1
          ;;
      esac
      ;;
    *)
      echo "Error: Unknown command '$1'. Use 'internsctl --help' for usage."
      exit 1
      ;;
  esac
done
