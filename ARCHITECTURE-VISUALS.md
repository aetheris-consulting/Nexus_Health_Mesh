# NEXUS Architecture - One-Page Visual

## System Overview (High-Level)

```mermaid
graph TB
    subgraph "Stakeholders"
        P((Patient))
        F((Family))
        D((Provider))
        I((Payer))
    end
    
    subgraph "NEXUS Mesh"
        direction LR
        L1[APIs<br/>Sync]
        L2[Events<br/>Async]
        L3[Ledger<br/>Audit]
    end
    
    subgraph "Intelligence"
        AI[Claude AI<br/>Coordinator]
        OBS[Observer<br/>Sentinel]
    end
    
    subgraph "Data"
        EHR[(Hospital<br/>EHR)]
        CLAIM[(Insurance<br/>System)]
    end
    
    P & F & D & I --> L1
    L1 <--> L2
    L2 <--> AI
    AI <--> OBS
    AI <--> EHR
    AI <--> CLAIM
    L1 & L2 --> L3
    
    style P fill:#4A90E2
    style F fill:#4A90E2
    style D fill:#E24A4A
    style I fill:#F5A623
    style AI fill:#7ED321
    style OBS fill:#D84AE2
    style L3 fill:#9B51E0
```

---

## The Three Layers (Detailed)

```mermaid
flowchart TB
    subgraph LAYER1["🔄 Layer 1: Federated APIs (Synchronous)"]
        direction LR
        API1[SMART-on-FHIR R4+]
        API2[OAuth 2.0 / OIDC]
        API3[mTLS Security]
        API1 ~~~ API2 ~~~ API3
    end
    
    subgraph LAYER2["📡 Layer 2: Event-Driven Mesh (Asynchronous)"]
        direction LR
        E1[Kafka / EventBridge]
        E2[MCP Routing]
        E3[Store & Forward]
        E1 ~~~ E2 ~~~ E3
    end
    
    subgraph LAYER3["🔒 Layer 3: Signed Audit Ledger (Immutable)"]
        direction LR
        L1[QLDB / Confidential Ledger]
        L2[Cryptographic Signatures]
        L3[Merkle Trees]
        L4[Optional Blockchain]
        L1 ~~~ L2 ~~~ L3 ~~~ L4
    end
    
    LAYER1 -.->|Real-time queries| DATA[(Data Sources)]
    LAYER2 -.->|Event notifications| DATA
    DATA -.->|All actions logged| LAYER3
    
    style LAYER1 fill:#e3f2fd
    style LAYER2 fill:#fff3e0
    style LAYER3 fill:#f3e5f5
```

---

## Data Flow (Request to Response)

```mermaid
sequenceDiagram
    autonumber
    participant U as User
    participant L1 as Layer 1<br/>(API)
    participant L2 as Layer 2<br/>(Events)
    participant AI as Claude AI
    participant L3 as Layer 3<br/>(Ledger)
    participant D as Data Source
    
    U->>L1: Request data
    L1->>L1: Authenticate<br/>Validate consent
    L1->>AI: Process request
    AI->>D: Fetch data<br/>(if authorized)
    D->>AI: Return data
    AI->>L2: Trigger events<br/>(async workflows)
    L2->>L2: Route to<br/>subscribers
    L1->>L3: Log request<br/>+ response
    AI->>L1: Formatted<br/>response
    L1->>U: Deliver data
    
    rect rgb(200, 255, 200)
        Note over L3: All steps<br/>immutably logged
    end
```

---

## Observer AI - Continuous Monitoring

```mermaid
graph LR
    subgraph "Clinical Activity"
        ORDER[Order Entered]
        MED[Medication Given]
        DC[Discharge Planned]
    end
    
    subgraph "Observer AI"
        MON[Monitor All<br/>Activity]
        RULES{Apply Safety<br/>Rules}
        ASSESS[Assess<br/>Severity]
    end
    
    subgraph "Action Taken"
        T1[Tier 1:<br/>Log only]
        T2[Tier 2:<br/>Alert team]
        T3[Tier 3:<br/>Urgent alert]
    end
    
    ORDER & MED & DC --> MON
    MON --> RULES
    RULES -->|Issue detected| ASSESS
    ASSESS -->|Low risk| T1
    ASSESS -->|Med risk| T2
    ASSESS -->|High risk| T3
    RULES -->|No issue| OK[Proceed<br/>Normally]
    
    style ASSESS fill:#FFE57F
    style T3 fill:#FF6B6B
    style T2 fill:#FFA500
    style OK fill:#7ED321
```

---

## Multi-Stakeholder Coordination

```mermaid
mindmap
  root((NEXUS<br/>Mesh))
    Patient
      View records
      Grant consent
      Message providers
      Track care plan
      Receive updates
    Family
      Monitor status
      Get notifications
      Support decisions
      Emergency access
    Providers
      Access records
      Coordinate care
      Document notes
      Order tests/meds
      Consult specialists
    Payers
      Review claims
      Prior authorization
      Care management
      Cost analysis
      Quality metrics
    Observer AI
      Monitor safety
      Detect patterns
      Alert issues
      Learn continuously
```

---

## Consent Management

```mermaid
stateDiagram-v2
    [*] --> NoConsent: Initial State
    NoConsent --> Requested: Patient action
    Requested --> Reviewing: Patient reviews
    Reviewing --> Approved: Patient signs
    Reviewing --> Denied: Patient declines
    Approved --> Active: Token issued
    Active --> Active: Queries allowed
    Active --> Revoked: Patient revokes
    Active --> Expired: Time limit
    Denied --> [*]
    Revoked --> [*]
    Expired --> [*]
    
    note right of Active
        Consent token includes:
        • Who can access
        • What data
        • For what purpose
        • Until when
    end note
```

---

## Technology Stack

```mermaid
graph TB
    subgraph "AI Layer"
        CLAUDE[Claude Opus 4.1<br/>Sonnet 4.5]
        BEDROCK[AWS Bedrock]
    end
    
    subgraph "Integration Layer"
        FHIR[HL7 FHIR R4+]
        OAUTH[OAuth 2.0 / OIDC]
        MTLS[mTLS]
    end
    
    subgraph "Event Layer"
        KAFKA[Kafka]
        EB[EventBridge]
        EG[Azure Event Grid]
    end
    
    subgraph "Storage Layer"
        QLDB[AWS QLDB]
        CL[Confidential Ledger]
        BLOCK[Optional Blockchain]
    end
    
    subgraph "Security Layer"
        HSM[HSM Key Storage]
        ENCRYPT[AES-256 Encryption]
        SIGN[RSA-4096 Signatures]
    end
    
    CLAUDE --> BEDROCK
    BEDROCK --> FHIR
    FHIR --> KAFKA
    KAFKA --> QLDB
    FHIR --> MTLS
    MTLS --> HSM
    HSM --> ENCRYPT
    HSM --> SIGN
    SIGN --> QLDB
    
    style CLAUDE fill:#7ED321
    style BEDROCK fill:#FF9900
    style KAFKA fill:#000000,color:#fff
    style QLDB fill:#9B51E0
```

---

## Deployment Architecture (Pitt-Anthropic)

```mermaid
graph TB
    subgraph "University of Pittsburgh"
        PITT[Claude for Education<br/>Infrastructure]
        BEDROCK[Amazon Bedrock]
        CLAUDE[Claude Opus 4.1<br/>Sonnet 4.5]
    end
    
    subgraph "NEXUS Deployment"
        MESH[NEXUS Mesh<br/>Coordinator]
        OBS[Observer AI]
        API[FHIR Gateway]
    end
    
    subgraph "UPMC Hospitals"
        EPIC[Epic EHR<br/>Systems]
        CLIN[Clinical Apps]
    end
    
    subgraph "Insurance Partners"
        PAYER[Insurance<br/>Systems]
    end
    
    PITT --> BEDROCK
    BEDROCK --> CLAUDE
    CLAUDE --> MESH
    MESH --> OBS
    MESH --> API
    API <--> EPIC
    API <--> CLIN
    API <--> PAYER
    
    style PITT fill:#4A90E2
    style CLAUDE fill:#7ED321
    style MESH fill:#E24AE2
    style EPIC fill:#FF6B6B
```

---

## Value Proposition

```mermaid
quadrantChart
    title NEXUS Positioning
    x-axis Low Technical Complexity --> High Technical Complexity
    y-axis Low Clinical Impact --> High Clinical Impact
    quadrant-1 High Impact, Complex
    quadrant-2 High Impact, Simple
    quadrant-3 Low Impact, Simple
    quadrant-4 Low Impact, Complex
    
    NEXUS: [0.7, 0.85]
    Traditional HIE: [0.6, 0.4]
    Basic Portal: [0.3, 0.3]
    ChatGPT Groups: [0.4, 0.5]
    Epic Care Link: [0.5, 0.5]
```

---

**These visuals are perfect for:**
- GitHub README.md (main page)
- Presentation slides
- Documentation
- Grant proposals
- Investor pitches

**All diagrams render automatically on GitHub!** 🎨
