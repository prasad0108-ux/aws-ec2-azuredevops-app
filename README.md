

# 🚀 EC2 Deployment Using Azure DevOps (VM-Based)

## 📌 Overview

This section covers **application deployment on an EC2 instance** using **Azure DevOps CI/CD pipelines**.
The deployment is **fully automated** and uses **SSH-based delivery** with a deployment script.

**Flow:**

```
GitHub → Azure DevOps Pipeline → EC2 (Ubuntu) → Node.js App (PM2)
```

---

## 🧱 Architecture

* **Compute**: Amazon EC2 (Ubuntu)
* **CI/CD**: Azure DevOps Pipelines
* **Source Code**: GitHub
* **Runtime**: Node.js
* **Process Manager**: PM2
* **Access Method**: SSH Service Connection

---

## 📂 EC2 Project Structure

```
.
├── app/
│   ├── app.js
│   └── package.json
│
├── ec2/
│   └── deploy.sh
│
├── pipelines/
│   └── azure-pipelines-ec2.yml
```

---

## 🔐 EC2 Configuration

### AMI

* **Ubuntu 22.04**

### Security Group Rules

| Port | Purpose     |
| ---- | ----------- |
| 22   | SSH         |
| 3000 | Application |

---

## 🔧 Software Installed on EC2 (One-Time Setup)

Executed manually after launching EC2:

```bash
sudo apt update -y
sudo apt install -y curl ca-certificates gnupg

curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

sudo npm install -g pm2
```

Verification:

```bash
node -v
npm -v
pm2 -v
```

---

## 🟢 Application Details

### Port

* Application listens on **port 3000**

### app.js

```js
const express = require('express');
const app = express();

const PORT = 3000;

app.get('/', (req, res) => {
  res.send('Hello from EC2 deployed via Azure DevOps 🚀');
});

app.listen(PORT, () => {
  console.log(`App running on port ${PORT}`);
});
```

---

## 📜 Deployment Script (EC2)

### `ec2/deploy.sh`

Purpose:

* Install dependencies
* Start or restart the app using PM2
* Ensure idempotent deployments

```bash
#!/bin/bash
set -e

APP_DIR="/home/ubuntu/app"
APP_NAME="ec2-app"

cd "$APP_DIR"

if [ ! -f package.json ]; then
  echo "package.json not found"
  exit 1
fi

npm install --omit=dev

if pm2 describe "$APP_NAME" > /dev/null 2>&1; then
  pm2 restart "$APP_NAME"
else
  pm2 start app.js --name "$APP_NAME"
fi
```

---

## 🔑 Azure DevOps SSH Service Connection

Created in **Azure DevOps → Project Settings → Service Connections**.

### Configuration

| Field          | Value          |
| -------------- | -------------- |
| Host           | EC2 Public IP  |
| Username       | ubuntu         |
| Authentication | Private Key    |
| Key Format     | OpenSSH `.pem` |
| Port           | 22             |

> `.ppk` keys are **not supported** — converted to `.pem`.

---

## ⚙️ Azure DevOps Pipeline (EC2)

### `pipelines/azure-pipelines-ec2.yml`

```yaml
trigger:
- main

pool:
  vmImage: ubuntu-latest

steps:
- checkout: self

- task: CopyFilesOverSSH@0
  displayName: "Copy application code to EC2"
  inputs:
    sshEndpoint: ec2-ssh-connection
    sourceFolder: app
    targetFolder: /home/ubuntu

- task: CopyFilesOverSSH@0
  displayName: "Copy deployment scripts"
  inputs:
    sshEndpoint: ec2-ssh-connection
    sourceFolder: ec2
    targetFolder: /home/ubuntu/ec2

- task: SSH@0
  displayName: "Run deployment script"
  inputs:
    sshEndpoint: ec2-ssh-connection
    runOptions: inline
    inline: |
      chmod +x /home/ubuntu/ec2/deploy.sh
      bash /home/ubuntu/ec2/deploy.sh
```

---

## 🧪 Verification Steps (Post-Deployment)

### 1️⃣ Check application files

```bash
ls -l /home/ubuntu/app
```

Expected:

```
app.js
package.json
node_modules/
```

---

### 2️⃣ Check PM2 process

```bash
pm2 list
```

Expected:

```
ec2-app   online
```

---

### 3️⃣ Browser access

```
http://<EC2_PUBLIC_IP>:3000
```

Expected output:

```
Hello from EC2 deployed via Azure DevOps 🚀
```

---

### 4️⃣ Enable PM2 persistence (Optional)

```bash
pm2 startup systemd
pm2 save
```

---

## ✅ EC2 Deployment Checklist

✔ EC2 created with Ubuntu
✔ Security Group allows 22 & 3000
✔ Node.js & PM2 installed
✔ SSH service connection configured
✔ Azure DevOps pipeline executed successfully
✔ App running and accessible

---

## 🎯 Key Takeaways

* EC2 deployment uses **VM-based model**
* Azure DevOps uses **SSH-based deployment**
* PM2 manages application lifecycle
* Manual infra, automated application deployment

