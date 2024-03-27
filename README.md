# DevSecOps Pipeline for SpringBoot Application
This repository is designed to implement DevSecOps practices for a SpringBoot application. The pipeline includes stages for building the application artifact, running unit tests, performing various security checks (SAST, DAST, dependency scanning, etc.), building and pushing a Docker container, deploying to Kubernetes, and conducting post-deployment checks.

## Prerequisites
* Jenkins with the necessary plugins (including Slack for notifications, Docker, Kubernetes, SonarQube, etc.)
* Maven for Java application build lifecycle management
* Docker for containerization
* Kubernetes for orchestration
* SonarQube for static application security testing (SAST)
* Trivy, OWASP ZAP, and other tools for security scanning
* Access to a Docker registry and Kubernetes cluster
## Usage
To use this pipeline:

* Ensure Jenkins is set up with credentials for Docker Hub, Kubernetes (kubeconfig), and any other services required by the pipeline.
* Add the Jenkinsfile to your Jenkins instance by creating a new pipeline job and pointing it to this file in your source code repository.
* Run the pipeline through Jenkins, which will automatically proceed through the stages defined in the Jenkinsfile.
* Pipeline Stages Explained
* Build Artifact: Compiles the code and packages it into a JAR file, skipping unit tests for speed.
* Unit Tests: Runs unit tests to ensure code integrity.
* Mutation Tests - PIT: Executes mutation testing to assess the quality of the unit tests.
* SonarQube - SAST: Analyzes the source code with SonarQube for potential security vulnerabilities.
* Vulnerability Scan - Docker: Performs security scanning on dependencies, Docker images, and Dockerfile configurations.
* Docker Build and Push: Builds the Docker image and pushes it to Docker Hub, tagging it with the Git commit ID.
* Vulnerability Scan - Kubernetes: Scans Kubernetes deployment configurations for security issues.
* K8s Deployment - DEV: Deploys the application to a development environment in Kubernetes and checks the rollout status.
* Integration Tests - DEV: Runs integration tests in the development environment, with automatic rollback on failure.
* OWASP ZAP - DAST: Performs dynamic application security testing using OWASP ZAP.
* Promote to PROD?: Awaits manual approval before promoting the application to the production environment.
* K8S CIS Benchmark: Runs CIS benchmark checks against Kubernetes components.
* K8S Deployment - PROD: Deploys the application to the production environment and verifies the deployment status.
### Post Actions
* Collects and publishes reports from unit tests, code coverage, mutation testing, and dependency checks.
* Sends a notification (e.g., via Slack) with the build result.
