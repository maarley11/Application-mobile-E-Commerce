---
name: Backend Feature Implementation
description: Standardized workflow for implementing backend features in the i-sib-tresorerie-service project, adhering to Spring Boot best practices and layered architecture.
---

# Backend Feature Implementation

This skill provides a standardized workflow for implementing backend features in the `i-sib-tresorerie-service` project. It ensures consistency with the existing Spring Boot architecture, specifically the Layered Architecture pattern (Controller -> Service -> Repository -> Data).

## Architectural Principles

1.  **Layered Architecture**:
    *   **Controller (`controller/`)**: Handles HTTP requests, input validation, and maps DTOs. LIGHT logic only.
    *   **Service (`service/`)**: Contains all business logic, transaction management, and complex validations.
    *   **Repository (`repository/`)**: Interface for data access (Spring Data JPA).
    *   **Domain/Entity (`domain/`)**: JPA Entities representing database tables.
2.  **DTO Pattern**:
    *   **NEVER** expose JPA Entities directly in the Controller API.
    *   Use **DTOs (Data Transfer Objects)** or Java **Records** for Request/Response payloads.
    *   Map between Entities and DTOs in the Service layer or using a Mapper.
3.  **Code Consistency**:
    *   Use Lombok (`@Data`, `@RequiredArgsConstructor`, `@Builder`) to reduce boilerplate.
    *   Use Constructor Injection (via `@RequiredArgsConstructor`) instead of `@Autowired` on fields.

## Workflow Steps

### 0. Requirement Check

Before starting implementation, **ALWAYS** check `sib-back-office/docs/api_registry.md` to find the exact endpoint specifications, request/response formats, and required behavior. This file acts as the source of truth for the API contract between frontend and backend.


### 1. Database & Entity (`domain/`)

Start by defining the data structure.

**File:** `src/main/java/com/bank/sgt/domain/[EntityName].java`

```java
package com.bank.sgt.domain;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

@Entity
@Table(name = "your_table_name")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class [EntityName] {
    @Id
    private String id; // or Long id with @GeneratedValue

    @Column(nullable = false)
    private String someField;
}
```

### 2. Repository (`repository/`)

Create the interface to access data.

**File:** `src/main/java/com/bank/sgt/repository/[EntityName]Repository.java`

```java
package com.bank.sgt.repository;

import com.bank.sgt.domain.[EntityName];
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface [EntityName]Repository extends JpaRepository<[EntityName], String> {
    // Define custom queries if needed
}
```

### 3. Service (`service/`)

Implement the business logic.

**File:** `src/main/java/com/bank/sgt/service/[EntityName]Service.java`

```java
package com.bank.sgt.service;

import com.bank.sgt.domain.[EntityName];
import com.bank.sgt.repository.[EntityName]Repository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
public class [EntityName]Service {

    private final [EntityName]Repository repository;

    public List<[EntityName]> getAll() {
        return repository.findAll();
    }
    
    // Implement other business methods
}
```

### 4. Controller (`controller/`)

Expose the endpoints.

**File:** `src/main/java/com/bank/sgt/controller/[EntityName]Controller.java`

```java
package com.bank.sgt.controller;

import com.bank.sgt.domain.[EntityName]; // Or DTO
import com.bank.sgt.service.[EntityName]Service;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/treasury/[resource-name]")
@RequiredArgsConstructor
public class [EntityName]Controller {

    private final [EntityName]Service service;

    @GetMapping
    public List<[EntityName]> getAll() {
        return service.getAll();
    }
}
```

## Rules

*   **REST Naming**: Use plural nouns for resources (e.g., `/api/treasury/accounts` not `/account`).
*   **Path Prefix**: All Treasury endpoints MUST start with `/api/treasury`.
*   **Response**: Ensure endpoints return appropriate HTTP status codes (200 OK, 201 Created, 404 Not Found).

## Resilience & Common Pitfalls

To ensure high availability and prevent 500 Internal Server Errors, **every backend feature** must adhere to the following resilience patterns:

### 1. Transaction Boundaries & Error Handling
Spring AOP proxies transaction methods. If a `RuntimeException` is thrown inside a `@Transactional` method, the proxy **immediately** marks the transaction as rollback-only.
* **Pitfall**: A `try-catch` inside the method catching the exception will result in an `UnexpectedRollbackException` on return.
* **Fix**: For read-only operations where you handle exceptions internally (e.g., returning an empty list on failure), explicitly tell Spring not to rollback:
  ```java
  @Transactional(readOnly = true, noRollbackFor = Exception.class)
  public List<YourDTO> safeGetList() { ... }
  ```

### 2. LAZY Loading (`LazyInitializationException`)
* **Pitfall**: Accessing a lazy-loaded relation (e.g., `deal.getCounterpartyEntity()`) outside an active Hibernate Session (or in a separate thread/stream mapping outside the transaction) causes a crash.
* **Fix**: 
  1. Prefer denormalized fields if available (e.g., use the `String counterparty` field directly).
  2. If the relation is strictly required, use `JOIN FETCH` in the repository `@Query` to load it eagerly.

### 3. Null-Safe DTO Mapping
* **Pitfall**: Mapping `null` BigDecimal or String fields directly into calculations or required DTO fields causes `NullPointerException`s that crash the API.
* **Fix**: Always provide sensible, type-safe fallbacks during mapping:
  ```java
  // Bad
  BigDecimal amount = entity.getAmount();
  // Good
  BigDecimal amount = entity.getAmount() != null ? entity.getAmount() : BigDecimal.ZERO;
  ```

### 4. Service Method Visibility Contract
* **Pitfall**: Creating a `private` method inside a `@Service` and expecting Spring AOP (e.g., `@Transactional` or `@Async`) to wrap it, or trying to call it from a Controller.
* **Fix**: Methods accessed by external layers (Controllers) or Spring proxies **must** be `public`.

### 5. Defensive Integration (Robustness)
* **Pitfall**: Assuming external files (CSV exports, configurations) or external APIs (Accounting, Market Data) will always be present or respond.
* **Fix**: Provide graceful degradation.
  * For file readers (e.g., Spring Batch `FlatFileItemReader`), set `.strict(false)` so missing files are skipped instead of crashing the application on boot.
  * If an external API URL isn't configured, log a warning and return empty data rather than crashing.
