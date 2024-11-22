#!/bin/bash

# Function to verify if Homebrew is installed on MacOS, if not, then install Homebrew
function verify_macos_homebrew() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS detected. Verifying if Homebrew is installed..."
        if ! command -v brew &> /dev/null; then
            echo "Homebrew is not installed. Exiting with error. Install Homebrew and re-run the script."
            exit 1
        else
            echo "Homebrew confirmed."
        fi
    fi
}

# Function to install the prerequisites required for the deployment of the
# AWS Zero Trust Reference Architecture with VM-Series on AWS
function install_prerequisites() {
  echo "Verifying prerequisites..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
      if ! brew list jq &>/dev/null; then
          brew install jq
      else
          echo "jq is already installed."
      fi
      if ! brew list wget &>/dev/null; then
          brew install wget
      else
          echo "wget is already installed."
      fi
  elif [[ "$OSTYPE" == "linux-gnu" ]]; then
      if ! command -v jq &>/dev/null; then
          sudo yum install -y jq
      else
          echo "jq is already installed."
      fi
      if ! command -v wget &>/dev/null; then
          sudo yum install -y wget
      else
          echo "wget is already installed."
      fi
  fi
}

# Function to check if Terraform is installed already, if not, then download and installed the version of Terraform as required.
function install_terraform() {
    # Sticking to Terraform v1.1.7 as it was used for the development of this code-base
    TERRAFORM_VERSION="1.1.7"

    # Check if terraform is already installed and display the version of terraform as installed
    [[ -f ${HOME}/bin/terraform ]] && echo "`${HOME}/bin/terraform version` already installed at ${HOME}/bin/terraform" && return 0

    # if macOS, we want to use brew to install tfenv (terraform version  manager)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v tfenv &> /dev/null; then
          echo "tfenv is installed."
        else
          echo "Installing tfenv..."
          brew install tfenv
        fi
        if tfenv list | grep -q $TERRAFORM_VERSION; then
          echo "Terraform version $TERRAFORM_VERSION is already installed."
        else
          echo "Installing Terraform version $TERRAFORM_VERSION..."
          tfenv install $TERRAFORM_VERSION
        fi
        tfenv use $TERRAFORM_VERSION
    elif [[ "$OSTYPE" == "linux-gnu" ]]; then
      # Else, download and install Terraform v1.1.7 for GNU Linux
      TERRAFORM_DOWNLOAD_URL=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].builds[].url' | egrep 'linux.*amd64' | egrep "${TERRAFORM_VERSION}" | egrep -v 'rc|beta|alpha')
      TERRAFORM_DOWNLOAD_FILE=$(basename $TERRAFORM_DOWNLOAD_URL)
      echo "Downloading Terraform v$TERRAFORM_VERSION from '$TERRAFORM_DOWNLOAD_URL'"
      # Download and install Terraform v1.1.7 as that is the version used for the development of this code-base.
      # TODO: Once Base and Ceiling versions have been validated, the code here will be modified to download the Ceiling version of terraform as required by the scripts in this code-base.
      mkdir -p ${HOME}/bin/ && cd ${HOME}/bin/ && wget $TERRAFORM_DOWNLOAD_URL && unzip $TERRAFORM_DOWNLOAD_FILE && rm $TERRAFORM_DOWNLOAD_FILE
          # Display an confirmation of the successful installation of Terraform.
      echo "Installed: `${HOME}/bin/terraform version`"
    fi
}

function deploy_vmseries_lab() {
    # Assuming that this setup script is being run from the cloned github repo, changing the current working directory to one from where Terraform will deploy the lab resources.
    cd "./terraform/vmseries" || Echo "./terraform/vmseries not found! Exiting." && exit 1

    # Initialize terraform
    echo "Initializing directory for lab resource deployment"
    terraform init

    # Deploy resources
    echo "Deploying Resources required for Palo Alto Networks Reference Architecture for Zero Trust with VM-Series on AWS"
    terraform apply -auto-approve

    if [ $? -eq 0 ]; then
        echo "AWS Zero Trust Reference Architecture with VM-Series Lab Deployment Completed successfully!"
    else
        echo "AWS Zero Trust Reference Architecture with VM-Series Lab Deployment Failed!"
        exit 1
    fi
}

verify_macos_homebrew
install_prerequisites
install_terraform
deploy_vmseries_lab