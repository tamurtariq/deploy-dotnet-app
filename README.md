🚀 .NET App Deployment Script for Linux (Ubuntu) with Nginx + SSL Support
This repository contains a powerful and easy-to-use deployment script that helps you deploy a .NET web app on a Linux server (Ubuntu) using Nginx as a reverse proxy. It works for both sample projects and apps cloned from a Git repository.

✅ What This Script Does
Installs all required dependencies:

-> .NET SDK
-> Nginx
-> Git

Deploys a sample .NET app or clones one from a Git repo

Publishes the app to /var/www/<project-name>

Sets up a systemd service to keep the app running

Configures Nginx as a reverse proxy to the app

Prepares for optional HTTPS/SSL configuration

## 📦 Requirements
Ubuntu 20.04+ server (tested on 22.04)

Root access or a user with sudo privileges

A domain name (optional but recommended)

## 🧠 How It Works (For Beginners)
You don’t need to be a .NET or Linux expert to use this!

## Steps Overview:
🧬 Clone this GitHub repo

🛠️ Run the deployment script

☁️ Your app will be up and running under your domain!

## 🛠️ How to Use
### 1. Clone This Repository
```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
```
Replace <your-repo> and <your-username> with the actual GitHub repo name and your GitHub username.

## 2. Make the Script Executable
```bash

chmod +x deploy-dotnet-app.sh
```
## 3. Run the Script
```bash
./deploy-dotnet-app.sh
```
You’ll be prompted for:

Project name – the name for your app directory and service

Domain name – your custom domain (like example.com)

Git repository URL – leave blank to generate a sample app

The script does everything for you: installs .NET, builds the app, sets up Nginx, creates a service, and more.

## 🌐 Accessing Your App
Once the script finishes, your app will be live at:

http://yourdomain.com/
If you're using a sample app and testing on localhost, you can also access via:

http://your-server-ip/

## 🔐 Adding HTTPS (SSL)
To enable HTTPS:

Upload your certificate to /etc/ssl/certs/<project>.crt
Upload your private key to /etc/ssl/private/<project>.key
Edit the Nginx config:

```bash
sudo nano /etc/nginx/sites-available/<project>
```
Uncomment the SSL lines in the config and reload Nginx:

```bash

sudo nginx -t
sudo systemctl reload nginx
```
## 🧹 Troubleshooting Tips
Port not accessible? Make sure firewall allows ports 80/443.

App not responding? Check the systemd service with:

```bash

sudo systemctl status <project-name>

```
Nginx config test fails? Double-check domain name and SSL paths.

## 💡 Bonus Ideas
Integrate Let's Encrypt using Certbot

Hook into CI/CD pipelines like GitHub Actions

Deploy multiple apps with HAProxy load balancing

👋 Contributing
Pull requests welcome! Feel free to open issues or suggest improvements.
