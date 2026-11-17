CodeAlpha_DockerWebServer

A containerized nginx web server built with Docker and Docker Compose, including health checks, container lifecycle management and troubleshooting exercises.

Built as part of the CodeAlpha DevOps Internship (Task 4: Web Server using Docker).

Table of Contents
Overview
Tech Stack
Project Structure
Prerequisites
Quick Start
Dockerfile Explained
Container Lifecycle
Monitoring and Health Checks
Troubleshooting Exercises
Docker Compose
Best Practices Followed

Overview

This project packages a static website and a custom nginx configuration into a Docker image, then runs it as a container. It demonstrates:

Docker containerization basics
Building and tagging images
The full container lifecycle (create, start, stop, restart, remove)
Health checks and monitoring
Diagnosing real container problems from logs
Repeatable deployment with Docker Compose
Tech Stack
Tool	Purpose
Docker	Containerization
Docker Compose	Multi-step configuration and deployment
nginx 1.27 (alpine)	Web server
HTML/CSS	Website content
Project Structure
CodeAlpha_DockerWebServer/
├── Dockerfile              # Image definition
├── docker-compose.yml      # Compose configuration
├── nginx.conf              # Custom nginx config (includes /health)
├── .dockerignore           # Files excluded from the image
├── site/
│   └── index.html          # Website content
└── README.md

Prerequisites
Docker Engine or Docker Desktop
Docker Compose v2 (docker compose)
Git

Verify the installation:

bash
docker --version
docker compose version
docker run hello-world
Quick Start
Option 1: Docker CLI
bash
# Clone the repository
git clone https://github.com/ja983/CodeAlpha_DockerWebServer.git
cd CodeAlpha_DockerWebServer

# Build the image
docker build -t codealpha-web:1.0 .

# Run the container
docker run -d --name web -p 8080:80 codealpha-web:1.0
Option 2: Docker Compose
bash
docker compose up -d --build

Then open http://localhost:8080 in your browser.

Test from the terminal:

bash
curl http://localhost:8080          # the website
curl http://localhost:8080/health   # health endpoint, returns OK
Dockerfile Explained
dockerfile
FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY site/ /usr/share/nginx/html/
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/health || exit 1
Instruction	Purpose
FROM nginx:1.27-alpine	Small, pinned base image
COPY nginx.conf ...	Replaces the default nginx config with a custom one
COPY site/ ...	Adds the website files
EXPOSE 80	Documents the container port
HEALTHCHECK	Lets Docker detect when the server stops responding
Container Lifecycle
Action	Command
List running containers	docker ps
List all containers	docker ps -a
Stop	docker stop web
Start	docker start web
Restart	docker restart web
Pause / unpause	docker pause web / docker unpause web
Remove	docker rm -f web
List images	docker images
Tag an image	docker tag codealpha-web:1.0 codealpha-web:latest
Remove an image	docker rmi codealpha-web:latest
Monitoring and Health Checks
Purpose	Command
Health status	docker inspect --format='{{.State.Health.Status}}' web
Live logs	docker logs -f web
CPU and memory	docker stats --no-stream
Running processes	docker top web
Shell inside container	docker exec -it web sh
Full configuration	docker inspect web

After about 30 seconds, docker ps shows the container as (healthy).

Troubleshooting Exercises
1. Port already in use
Problem: Starting a second container on port 8080 fails with "port is already allocated".
Diagnosis: docker ps showed the first container already bound to 8080.
Fix: Map the second container to a different host port (-p 8081:80).
2. Invalid nginx configuration
Problem: A container built with a broken nginx.conf exits immediately (Exited (1)).
Diagnosis: docker ps -a showed the exit status, and docker logs showed the nginx syntax error.
Fix: Restored the valid config, rebuilt the image and removed the broken container and image.
3. Main process stopped
Problem: Running nginx -s stop inside the container made the container exit.
Diagnosis: A container lives only as long as its main process.
Fix: docker start web, and added restart: unless-stopped in Compose to automate recovery.
4. Wrong file path
Problem: docker exec web ls /usr/share/nginx/htmll returned "No such file or directory".
Diagnosis: Typo in the path, confirmed by listing /usr/share/nginx.
Fix: Used the correct path /usr/share/nginx/html.
Docker Compose
yaml
services:
  web:
    build: .
    image: codealpha-web:1.0
    container_name: codealpha-web
    ports:
      - "8080:80"
    restart: unless-stopped
    volumes:
      - ./site:/usr/share/nginx/html:ro
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://127.0.0.1/health"]
      interval: 30s
      timeout: 3s
      retries: 3
Command	Description
docker compose up -d --build	Build and start in the background
docker compose ps	Show service status
docker compose logs -f	Follow logs
docker compose down	Stop and remove everything

Because ./site is mounted as a read-only volume, editing site/index.html and refreshing the browser shows changes immediately, with no rebuild needed.

Best Practices Followed
Small base image (alpine) for a smaller attack surface and faster pulls
Pinned image version instead of latest for reproducible builds
.dockerignore keeps unnecessary files out of the image
HEALTHCHECK for automatic detection of failures
restart: unless-stopped for self-healing
Read-only volume mount for site content
One process per container
Configuration defined as code with Docker Compose
