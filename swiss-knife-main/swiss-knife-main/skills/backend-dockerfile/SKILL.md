---
name: backend-dockerfile
description: Best practices and templates for creating production-ready multi-stage Dockerfiles for backend services (Java/Spring Boot, generic backend). Focuses on security, size optimization, layer caching, and non-root execution.
origin: ECC
---

# Backend Dockerfile Patterns

Guidelines for writing robust, secure, and optimized Dockerfiles for backend applications.

## When to Activate

- Creating a new `Dockerfile` for a backend service
- Refactoring an existing `Dockerfile` to reduce image size or improve build times
- Addressing container security vulnerabilities (e.g., running as root, exposed secrets)
- Optimizing Docker layer caching for faster CI/CD pipelines
- Reviewing backend PRs containing Dockerfile changes

## Standard Implementation

The gold standard for a backend Dockerfile is the **Multi-Stage Build**. This approach separates the build environment (which needs compilers, SDKs, and source code) from the runtime environment (which only needs the compiled artifact and a minimal runtime).

Below is the standard template for a Java Spring Boot application.

```dockerfile
# GOOD: Multi-stage build for a Java Backend Application

# ==========================================
# Stage 1: Build (Compiler, SDK, Source Code)
# ==========================================
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /app

# Step A: Copy dependency descriptors FIRST.
# This maximizes layer caching. We only want to re-download dependencies if pom.xml changes.
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Step B: Download dependencies offline. 
RUN ./mvnw dependency:go-offline -B

# Step C: Copy source code LAST.
# Code changes frequently, so this layer will invalidate often.
COPY src src

# Step D: Compile the application.
RUN ./mvnw package -DskipTests

# ==========================================
# Stage 2: Production Runtime (Minimal, Secure)
# ==========================================
FROM eclipse-temurin:21-jre-alpine AS runner
WORKDIR /app

# 1. Security: Create and use a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser:appgroup

# 2. Optimization: Copy ONLY the compiled artifact from the builder stage
# Set ownership to the non-root user during the copy to prevent permission issues.
COPY --from=builder --chown=appuser:appgroup /app/target/*.jar app.jar

# 3. Explicit Documentation: Expose the port the app runs on
EXPOSE 8080

# 4. Resilience: Configure a healthcheck
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -qO- http://localhost:8080/actuator/health/readiness || exit 1

# 5. Execution: Use the JSON array (exec) form to ensure signals pass correctly
CMD ["java", "-jar", "app.jar"]
```

## Common Pitfalls

- **BAD: Single Stage & Running as Root**: Bundles SDKs (like JDK or Node with NPM) into production, increasing the attack surface and image size. Runs as the root user by default.
- **BAD: Poor Layer Caching**: Copying `.` (everything) before fetching dependencies. Every code change triggers a full dependency re-download.
- **BAD: Shell Form CMD**: Using `CMD java -jar app.jar` starts the app as a child of `/bin/sh -c`. It will not receive `SIGTERM` signals correctly when stopping the container, leading to ungraceful terminations.

### Anti-Pattern Example

```dockerfile
# BAD: Do NOT use this structure
FROM openjdk:17
WORKDIR /app
# Invalidates cache on ANY file change (including READMEs)
COPY . .
# Re-downloads dependencies every time code changes
RUN mvn clean install
# Runs as root, uses shell form CMD
CMD java -jar target/app.jar
```

## The .dockerignore File Requirement

A secure and optimized Dockerfile relies on a proper `.dockerignore` file in the same directory. Without it, sensitive local files or heavy directories might be added to the image context.

```dockerignore
# .dockerignore
.git
.idea
.vscode
target/
build/
node_modules/
*.log
.env
.env.*
Dockerfile
docker-compose*.yml
```

## Review Checklist

Before finalizing or reviewing a Backend Dockerfile, verify the following:

- [ ] **Multi-stage build**: Is a lightweight `jre` or `alpine` image used for the final runtime stage?
- [ ] **Layer Caching**: Are dependency files (e.g., `pom.xml`, `package.json`, `requirements.txt`) copied and resolved *before* the application source code?
- [ ] **Non-root execution**: Is a specific user and group created, and is the `USER` directive applied before running the app?
- [ ] **Permissions**: Are artifacts copied via `COPY --from=builder` assigned ownership via `--chown=user:group`?
- [ ] **Signal Handling**: Is `CMD` or `ENTRYPOINT` defined using the exec JSON array format `["executable", "arg1"]`?
- [ ] **Observability**: Is a reasonable `HEALTHCHECK` defined?
- [ ] **Context**: Is an appropriate `.dockerignore` file present to prevent leaking secrets and bloating the context?
