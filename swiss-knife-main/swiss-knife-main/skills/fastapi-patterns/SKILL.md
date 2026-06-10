---
description: Patterns and best practices for developing scalable, async-first APIs with FastAPI.
---

# FastAPI Development Patterns

This skill defines the preferred architecture, patterns, and best practices for building robust and performant APIs using FastAPI.

## 1. Async-First Philosophy
- **Rule**: Never run blocking I/O directly in an `async def` route path operation.
- **Pattern**: 
    - Use `httpx` instead of `requests`.
    - Use `sqlalchemy.ext.asyncio` with `asyncpg` for database access.
    - If you must use a sync blocking library, define the route as `def` (FastAPI runs it in a threadpool) or use `fastapi.concurrency.run_in_threadpool` inside an `async def`.
- **Background Tasks**: Offload heavy computation (like Document Parsing, LLM calls) to a background worker (e.g., SAQ, Celery) instead of `BackgroundTasks` which blocks the event loop shutdown.

## 2. Dependency Injection
- **Rule**: Extensively use `Depends()` for database sessions, current user retrieval, and shared logic.
- **Pattern**:
    ```python
    @router.get("/")
    async def get_items(db: AsyncSession = Depends(get_async_session)):
        ...
    ```

## 3. Pydantic and Schema Validation
- **Rule**: Separate ORM models (SQLAlchemy) from validation schemas (Pydantic).
- **Pattern**:
    - Use `BaseModel` to define `Create`, `Update`, and `Response` objects.
    - Always set `model_config = ConfigDict(from_attributes=True)` or `class Config: from_attributes = True` on `Response` models so FastAPI can serialize SQLAlchemy ORMs.

## 4. Architecture and File Structure
- **Rule**: Use a domain-driven / modular design over flat files.
- **Pattern**:
    - Group by feature module (e.g., `app/cv/`, `app/jobs/`).
    - Inside a module: `router.py`, `schemas.py`, `service.py`, `models.py` (if not global).
    - Expose routers in a central `main.py` via `app.include_router(module_router)`.

## 5. Error Handling
- **Rule**: Catch expected business logic errors in the service layer (raising custom exceptions or returning status objects) and map them to `HTTPException` in the router.
- **Pattern**:
    ```python
    # router.py
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    ```

## 6. Testing
- **Rule**: Write integration tests using `AsyncClient` from `httpx` and override dependencies.
- **Pattern**:
    ```python
    app.dependency_overrides[get_async_session] = override_get_async_session
    ```
