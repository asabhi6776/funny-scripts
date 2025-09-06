# Automation Scripts

This repository contains a collection of scripts I’ve written to automate tasks and save time. I created them because I value efficiency—and, honestly, I’m a bit lazy! These scripts are designed to simplify repetitive tasks, enhance productivity, and make life a little easier.

## Scripts Overview

### 1. `password-generator.py`
A Python script to generate secure passwords with a mix of uppercase, lowercase, digits, and special characters.

- **Usage**: Run the script and input the desired password length (minimum 8 characters).
- **Example**:
  ```sh
  python3 password-generator.py
  ```

### 2. `current_world_time.sh`
A Bash script to fetch the current time in a specified timezone.

- **Usage**: Provide a valid timezone as an argument.
- **Example**:
  ```sh
  ./current_world_time.sh Asia/Kolkata
  ```

### 3. `self-signed-certs.sh`
A Bash script to generate self-signed CA and wildcard certificates.

  - **Features**:
    - Prompts for user inputs like CA name, domain, and validity period.
    - Generates private keys, CSR, and certificates.
  - **Usage**: Run the script and follow the prompts.
  - **Example**:
    ```sh
    ./self-signed-certs.sh
    ```

### 4. `vfetch.sh`
A Bash script to display system information in a visually appealing format.

  - **Features**:
    - Displays user, OS, CPU, memory, disk usage, and more.
    - Includes colorful icons for better readability.
  - **Usage**: Run the script directly.
  - **Example**:
    ```sh
    ./vfetch.sh
    ```

### 5. `memos.sh`
A Bash script to create memos and send them to a specified API.

  - **Features**:
    - Supports tags and content formatting.
    - Requires `MEMOS_URI` and `MEMOS_TOKEN` environment variables.
  - **Usage**:
    ```sh
    MEMOS_URI="https://example.com" MEMOS_TOKEN="your_token" ./memos.sh "Your memo content" -t tag1,tag2
    ```

## Prerequisites
  - **Python**: Required for `password-generator.py`.
  - **Bash**: Required for all shell scripts.
  - **Dependencies**: Some scripts may require additional tools like `openssl`, `jq`, or `curl`.

## License
Feel free to use, modify, and share these scripts. Contributions are welcome!
