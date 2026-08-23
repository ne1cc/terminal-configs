---
name: mermaid-architect
description: Generates visual system architectures, database ER diagrams, and sequence flows using clean Mermaid markup.
---

# Mermaid Architecture Designer

Generate clean, valid Mermaid diagrams to visualize distributed systems, state transitions, sequence workflows, and entity relationships.

## Key Diagram Types

### 1. System Architecture / Flow
```mermaid
graph TD
    Client[Client UI / Extension] -->|WebSocket / HTTPS| Gateway[API Gateway]
    Gateway --> Auth[Auth Middleware]
    Gateway --> Service[Core Engine]
    Service --> Cache[(Redis Cache)]
    Service --> DB[(PostgreSQL)]
```

### 2. Sequence Workflow
```mermaid
sequenceDiagram
    autonumber
    actor User
    participant UI as Client Interface
    participant Svc as Backend Service
    participant Engine as Calculation Engine

    User->>UI: Trigger Action
    UI->>Svc: Send Request payload
    Svc->>Engine: Run Computation
    Engine-->>Svc: Computation Results
    Svc-->>UI: Return Response
    UI-->>User: Render View
```

### 3. Entity-Relationship Schema
```mermaid
erDiagram
    USER ||--o{ ORDER : places
    USER {
        string id PK
        string email
        timestamp created_at
    }
    ORDER {
        string id PK
        string user_id FK
        float total_amount
    }
```
