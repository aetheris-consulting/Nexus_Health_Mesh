# NEXUS Health Mesh - Process Map Visuals

This document contains all process flow diagrams for the NEXUS Health Mesh architecture.

**Format**: Mermaid diagrams (render automatically on GitHub)

---

## 1. Overall System Architecture

```mermaid
graph TB
    subgraph "Stakeholders"
        P[Patient]
        F[Family]
        D[Doctor/Provider]
        I[Insurance/Payer]
    end
    
    subgraph "NEXUS Mesh - Three Layers"
        API[Layer 1: APIs<br/>SMART-on-FHIR + OAuth]
        EVENT[Layer 2: Events<br/>Kafka/EventBridge]
        LEDGER[Layer 3: Audit Ledger<br/>QLDB/Blockchain]
    end
    
    subgraph "Core Services"
        OBS[Observer AI<br/>Quality/Safety Sentinel]
        CONSENT[Consent Manager<br/>Token Validation]
        AI[Claude AI<br/>Coordination Engine]
    end
    
    subgraph "Data Sources"
        EHR1[(Hospital A<br/>EHR)]
        EHR2[(Hospital B<br/>EHR)]
        PAYER[(Insurance<br/>System)]
    end
    
    P --> API
    F --> API
    D --> API
    I --> API
    
    API --> AI
    EVENT --> AI
    AI --> CONSENT
    
    CONSENT --> EHR1
    CONSENT --> EHR2
    CONSENT --> PAYER
    
    AI --> OBS
    OBS --> EVENT
    
    API --> LEDGER
    EVENT --> LEDGER
    
    style P fill:#e1f5ff
    style F fill:#e1f5ff
    style D fill:#ffe1e1
    style I fill:#fff4e1
    style AI fill:#e1ffe1
    style OBS fill:#ffe1f5
    style LEDGER fill:#f5e1ff
```

---

## 2. Care Transition Workflow (Hospital to Hospital)

```mermaid
sequenceDiagram
    participant P as Patient
    participant HA as Hospital A<br/>(Discharging)
    participant AI as NEXUS AI<br/>Coordinator
    participant OBS as Observer<br/>Sentinel
    participant LED as Audit<br/>Ledger
    participant HB as Hospital B<br/>(Receiving)
    
    Note over HA: Day 0: Patient Discharged
    
    HA->>HA: Doctor completes<br/>discharge summary
    HA->>AI: Generate FHIR bundle
    AI->>HA: Standardized summary
    HA->>HA: Doctor reviews<br/>& signs (RSA-4096)
    HA->>LED: Record signature<br/>+ hash
    
    HA->>AI: Publish event:<br/>patient.transfer.initiated
    AI->>OBS: Validate consent<br/>+ care plan
    OBS->>AI: ✓ Approved
    
    AI->>HB: Notify: Incoming<br/>transfer
    HB->>AI: Request discharge<br/>summary (with consent token)
    AI->>HA: Validate token
    HA->>AI: Send signed FHIR<br/>bundle
    AI->>HB: Deliver summary
    
    HB->>LED: Record receipt<br/>+ timestamp
    LED->>LED: Create Merkle<br/>proof
    
    Note over HB: Day 1: Patient Arrives
    
    HB->>AI: Query: Last echo?
    AI->>HA: Fetch with consent
    HA->>AI: Return echo results
    AI->>HB: Deliver data
    
    HB->>LED: Log query + response
    
    Note over P,HB: Care continues seamlessly
    
    rect rgb(200, 255, 200)
        Note over LED: All actions logged<br/>immutably
    end
```

---

## 3. Observer AI Detection & Escalation

```mermaid
flowchart TD
    START([Patient Order<br/>Entered in EHR])
    
    START --> CHECK{Observer AI<br/>Monitors}
    
    CHECK --> SAFE{Safety<br/>Issue?}
    
    SAFE -->|No Issues| APPROVE[Order Proceeds<br/>Normally]
    
    SAFE -->|Tier 1:<br/>Quality Drift| T1[Alert Team Lead<br/>SLA: 24 hours]
    SAFE -->|Tier 2:<br/>Material Impact| T2[Alert Dept Head<br/>+ Compliance<br/>SLA: 8 hours]
    SAFE -->|Tier 3:<br/>Imminent Harm| T3[URGENT Alert<br/>CMO + Legal<br/>SLA: 1 hour]
    
    T1 --> EVIDENCE1[Generate Evidence<br/>Bundle]
    T2 --> EVIDENCE2[Generate Evidence<br/>Bundle]
    T3 --> EVIDENCE3[Generate Evidence<br/>Bundle + Page]
    
    EVIDENCE1 --> LOG1[(Log to<br/>Audit Ledger)]
    EVIDENCE2 --> LOG2[(Log to<br/>Audit Ledger)]
    EVIDENCE3 --> LOG3[(Log to<br/>Audit Ledger)]
    
    LOG1 --> REVIEW1{Staff<br/>Review}
    LOG2 --> REVIEW2{CAPA<br/>Required}
    LOG3 --> REVIEW3{Immediate<br/>Intervention}
    
    REVIEW1 --> |Valid| FIX1[Process<br/>Improvement]
    REVIEW1 --> |False Positive| TUNE1[Calibrate<br/>Observer]
    
    REVIEW2 --> |Valid| FIX2[Root Cause<br/>Analysis]
    REVIEW2 --> |False Positive| TUNE2[Calibrate<br/>Observer]
    
    REVIEW3 --> |Valid| FIX3[Immediate Fix<br/>+ Investigation]
    REVIEW3 --> |False Positive| TUNE3[Emergency<br/>Review]
    
    FIX1 --> LEARN[Observer<br/>Learns]
    FIX2 --> LEARN
    FIX3 --> LEARN
    TUNE1 --> LEARN
    TUNE2 --> LEARN
    TUNE3 --> LEARN
    
    APPROVE --> END([Care<br/>Continues])
    LEARN --> END
    
    style T3 fill:#ff6b6b
    style EVIDENCE3 fill:#ff6b6b
    style REVIEW3 fill:#ff6b6b
    style FIX3 fill:#ff6b6b
    
    style T2 fill:#ffa500
    style EVIDENCE2 fill:#ffa500
    
    style T1 fill:#ffeb3b
    style EVIDENCE1 fill:#ffeb3b
    
    style LEARN fill:#4caf50
```

---

## 4. Consent Token Flow

```mermaid
sequenceDiagram
    participant P as Patient
    participant APP as Patient App
    participant CONSENT as Consent<br/>Manager
    participant HA as Hospital A<br/>(Data Owner)
    participant HB as Hospital B<br/>(Requestor)
    
    P->>APP: I want Hospital B to<br/>see my records
    APP->>P: What can they access?<br/>• Medications<br/>• Lab results<br/>• Allergies
    P->>APP: Approve (signs)
    
    APP->>CONSENT: Create consent token<br/>(JWT format)
    CONSENT->>CONSENT: Generate token:<br/>• Patient ID<br/>• Authorized org: HB<br/>• Resources: Med, Labs, Allergies<br/>• Purpose: Treatment<br/>• Expires: 1 year
    
    CONSENT->>P: Sign token<br/>(Patient private key)
    P->>CONSENT: Signed token
    CONSENT->>HA: Register consent
    CONSENT->>HB: Deliver token
    
    Note over P,HB: Hospital B Queries Data
    
    HB->>HA: GET /Patient/123/Medication<br/>Authorization: Bearer {token}
    HA->>HA: Validate token:<br/>✓ Signature valid<br/>✓ Not expired<br/>✓ HB authorized<br/>✓ Medication in scope
    
    alt Token Valid
        HA->>HB: Return medication data
        HB->>HB: Use data for treatment
        HA->>CONSENT: Log access
        CONSENT->>CONSENT: Audit trail
    else Token Invalid
        HA->>HB: 403 Forbidden<br/>Reason: Not authorized
        HA->>CONSENT: Log denial
    end
    
    Note over P: Patient Revokes Access
    
    P->>APP: Revoke Hospital B's<br/>access
    APP->>CONSENT: Revoke token
    CONSENT->>HA: Invalidate token
    CONSENT->>HB: Notify: Access revoked
    
    HB->>HA: GET /Patient/123/Medication<br/>Authorization: Bearer {token}
    HA->>HB: 401 Unauthorized<br/>Token revoked
    
    rect rgb(255, 200, 200)
        Note over P,HB: Access blocked
    end
```

---

## 5. Multi-Stakeholder Coordination (Cancer Treatment)

```mermaid
graph LR
    subgraph "Patient Journey"
        P[Patient:<br/>Sarah, 45<br/>Stage 2 Breast Cancer]
    end
    
    subgraph "Clinical Team"
        ONCO[Oncologist<br/>Dr. Smith]
        SURG[Surgeon<br/>Dr. Jones]
        RADIO[Radiologist<br/>Dr. Lee]
        PCP[Primary Care<br/>Dr. Brown]
    end
    
    subgraph "Support Network"
        FAM[Family<br/>Husband + Sister]
        SW[Social Worker]
        NUTR[Nutritionist]
    end
    
    subgraph "NEXUS AI Coordinator"
        AI[Claude AI<br/>Treatment<br/>Coordinator]
    end
    
    subgraph "Administrative"
        INS[Insurance<br/>UnitedHealth]
        SCHED[Scheduler]
        PHARM[Pharmacy]
    end
    
    P <--> AI
    FAM <--> AI
    
    AI <--> ONCO
    AI <--> SURG
    AI <--> RADIO
    AI <--> PCP
    
    AI <--> SW
    AI <--> NUTR
    
    AI <--> INS
    AI <--> SCHED
    AI <--> PHARM
    
    ONCO -.->|Treatment Plan| AI
    SURG -.->|Surgery Date| AI
    RADIO -.->|Imaging Results| AI
    
    AI -.->|Unified Updates| P
    AI -.->|Family Digest| FAM
    AI -.->|Prior Auth| INS
    
    style P fill:#e1f5ff,stroke:#333,stroke-width:3px
    style AI fill:#e1ffe1,stroke:#333,stroke-width:3px
    style FAM fill:#ffe1e1
    style INS fill:#fff4e1
```

---

## 6. Event-Driven Mesh Architecture

```mermaid
flowchart TB
    subgraph "Hospital A"
        EHR_A[(EHR System)]
        GATE_A[Event Gateway<br/>Kafka]
        APP_A[Clinical App]
    end
    
    subgraph "NEXUS Mesh - Event Bus"
        ROUTE{Event Router<br/>MCP Protocol}
        QUEUE[(Event Queue<br/>Store & Forward)]
    end
    
    subgraph "Hospital B"
        GATE_B[Event Gateway<br/>EventBridge]
        EHR_B[(EHR System)]
        APP_B[Clinical App]
    end
    
    subgraph "Insurance"
        GATE_I[Event Gateway<br/>Azure Event Grid]
        SYS_I[(Claims System)]
    end
    
    subgraph "Observer & Audit"
        OBS[Observer AI<br/>Monitors Events]
        LED[(Audit Ledger<br/>Immutable Log)]
    end
    
    EHR_A -->|procedure.performed| GATE_A
    APP_A -->|consult.response| GATE_A
    
    GATE_A -->|Publish| ROUTE
    
    ROUTE -->|Store| QUEUE
    ROUTE -->|Route| GATE_B
    ROUTE -->|Route| GATE_I
    ROUTE -->|Monitor| OBS
    
    GATE_B -->|Deliver| EHR_B
    GATE_B -->|Deliver| APP_B
    
    GATE_I -->|Deliver| SYS_I
    
    OBS -->|Alert if needed| GATE_A
    OBS -->|Alert if needed| GATE_B
    
    ROUTE -->|Log all events| LED
    OBS -->|Log alerts| LED
    
    QUEUE -.->|Replay if needed| ROUTE
    
    style ROUTE fill:#e1ffe1
    style QUEUE fill:#ffe1e1
    style OBS fill:#ffe1f5
    style LED fill:#f5e1ff
```

---

## 7. Insurance Authorization Flow

```mermaid
sequenceDiagram
    participant D as Doctor
    participant EHR as Hospital EHR
    participant AI as NEXUS AI
    participant INS as Insurance AI
    participant OBS as Observer
    
    D->>EHR: Order MRI for patient
    EHR->>AI: Event: auth.request.created
    
    AI->>INS: Authorization request:<br/>• Diagnosis: L4-L5 radiculopathy<br/>• Prior treatment: PT x 8 weeks<br/>• Clinical notes: Pain 8/10
    
    INS->>INS: Check policy:<br/>• MRI requires failed PT<br/>• PT duration: 6 weeks min
    
    alt Approval Path
        INS->>AI: APPROVED<br/>Ref: AUTH-789123
        AI->>EHR: Update: Authorized
        AI->>D: Notify: MRI approved
        EHR->>EHR: Schedule MRI
    else Denial Path
        INS->>AI: DENIED<br/>Reason: Try X-ray first<br/>Appeal info attached
        AI->>EHR: Update: Denied
        AI->>D: Notify: Denied + appeal option
        
        D->>AI: Appeal with:<br/>• ACR guidelines<br/>• Contraindication to X-ray<br/>• Clinical urgency
        
        AI->>INS: Appeal submission
        INS->>INS: Peer review
        INS->>AI: APPROVED on appeal
        AI->>EHR: Update: Approved
    end
    
    AI->>OBS: Log decision path
    OBS->>OBS: Monitor:<br/>• Time to decision<br/>• Appropriateness<br/>• Pattern detection
    
    alt Concern Detected
        OBS->>AI: Alert: Multiple denials<br/>for similar cases
        AI->>D: Notify: Pattern detected<br/>Consider policy discussion
    end
    
    rect rgb(200, 255, 200)
        Note over AI,OBS: All logged to audit ledger
    end
```

---

## 8. Federated Learning Network

```mermaid
graph TB
    subgraph "Hospital A - San Francisco"
        DATA_A[(Local Patient Data<br/>10,000 patients)]
        MODEL_A[Local Model Training]
        DATA_A --> MODEL_A
    end
    
    subgraph "Hospital B - New York"
        DATA_B[(Local Patient Data<br/>15,000 patients)]
        MODEL_B[Local Model Training]
        DATA_B --> MODEL_B
    end
    
    subgraph "Hospital C - Chicago"
        DATA_C[(Local Patient Data<br/>8,000 patients)]
        MODEL_C[Local Model Training]
        DATA_C --> MODEL_C
    end
    
    subgraph "NEXUS Federated Learning Hub"
        AGG[Secure Aggregator<br/>Differential Privacy ε=1.0]
        GLOBAL[Global Model<br/>Trained on 33K patients]
    end
    
    MODEL_A -.->|Model Updates Only<br/>NO Raw Data| AGG
    MODEL_B -.->|Model Updates Only<br/>NO Raw Data| AGG
    MODEL_C -.->|Model Updates Only<br/>NO Raw Data| AGG
    
    AGG -->|Aggregate<br/>+ Add Noise| GLOBAL
    
    GLOBAL -.->|Improved Model| MODEL_A
    GLOBAL -.->|Improved Model| MODEL_B
    GLOBAL -.->|Improved Model| MODEL_C
    
    MODEL_A -->|Better Predictions| DATA_A
    MODEL_B -->|Better Predictions| DATA_B
    MODEL_C -->|Better Predictions| DATA_C
    
    subgraph "Privacy Guarantees"
        PROOF[Mathematical Proof:<br/>ε-differential privacy<br/>Re-identification risk < 1%]
    end
    
    AGG -.->|Validated by| PROOF
    
    style DATA_A fill:#e1f5ff
    style DATA_B fill:#e1f5ff
    style DATA_C fill:#e1f5ff
    style AGG fill:#ffe1e1
    style GLOBAL fill:#e1ffe1
    style PROOF fill:#fff4e1
```

---

## 9. Patient AI Companion Interaction

```mermaid
flowchart LR
    subgraph "Patient Experience"
        P[Patient:<br/>John, 62<br/>Post-surgery]
        APP[Mobile App<br/>Claude-powered]
    end
    
    subgraph "NEXUS Services"
        AI[Claude AI<br/>Patient Companion]
        MESH[NEXUS Mesh<br/>Coordinator]
    end
    
    subgraph "Healthcare Team"
        SURG[Surgeon]
        NURSE[Home Health<br/>Nurse]
        PHARM[Pharmacist]
    end
    
    P -->|"How much pain<br/>is normal?"| APP
    APP -->|Query| AI
    AI -->|Check discharge<br/>instructions| MESH
    MESH -->|Retrieve| SURG
    AI -->|"3-4/10 is normal.<br/>8+ call doctor.<br/>Your last report: 5/10"| APP
    APP -->|Display| P
    
    P -->|"Can I take<br/>ibuprofen?"| APP
    APP -->|Query| AI
    AI -->|Check meds<br/>+ interactions| MESH
    MESH -->|Retrieve| PHARM
    AI -->|"No - you're on blood<br/>thinners. Use Tylenol<br/>instead."| APP
    
    P -->|"I feel dizzy"| APP
    APP -->|Alert| AI
    AI -->|Assess severity<br/>+ context| MESH
    AI -->|URGENT:<br/>Patient dizzy| NURSE
    NURSE -->|Schedule home<br/>visit today| MESH
    MESH -->|Update| AI
    AI -->|"Nurse will visit<br/>at 2pm today"| APP
    
    style P fill:#e1f5ff
    style AI fill:#e1ffe1
    style APP fill:#ffe1e1
```

---

## 10. Three-Layer Mesh - Data Flow

```mermaid
graph TB
    subgraph "User Actions"
        U[User Query or<br/>Clinical Event]
    end
    
    subgraph "Layer 1: Synchronous APIs"
        API[SMART-on-FHIR<br/>REST API]
        AUTH[OAuth 2.0 +<br/>mTLS Auth]
        CONSENT[Consent Token<br/>Validation]
    end
    
    subgraph "Layer 2: Asynchronous Events"
        PUB[Event Publisher]
        KAFKA[Kafka/EventBridge<br/>Event Bus]
        SUB[Event Subscribers]
    end
    
    subgraph "Layer 3: Immutable Audit"
        HASH[Hash Document]
        SIGN[Digital Signature]
        LEDGER[(QLDB/Blockchain<br/>Ledger)]
        MERKLE[Merkle Tree<br/>Verification]
    end
    
    U --> API
    API --> AUTH
    AUTH -->|Valid?| CONSENT
    
    CONSENT -->|Authorized| DATA[(EHR Data)]
    CONSENT -->|Also trigger| PUB
    
    PUB --> KAFKA
    KAFKA --> SUB
    SUB --> PROCESS[Process Event]
    
    API --> HASH
    PUB --> HASH
    HASH --> SIGN
    SIGN --> LEDGER
    LEDGER --> MERKLE
    
    MERKLE -.->|Verify| API
    MERKLE -.->|Verify| PUB
    
    DATA --> RESPONSE[API Response]
    PROCESS --> NOTIFICATION[Event Notification]
    
    RESPONSE --> USER[User Receives<br/>Data]
    NOTIFICATION --> USER
    
    style API fill:#e1f5ff
    style KAFKA fill:#ffe1e1
    style LEDGER fill:#f5e1ff
    style USER fill:#e1ffe1
```

---

## How to Use These Diagrams

### **1. Add to GitHub Repository**

Create a new file: `docs/process-maps.md` and paste this content.

GitHub will automatically render Mermaid diagrams!

### **2. Add to README**

Add a link in your main README.md:
```markdown
## 📊 Process Maps & Architecture Diagrams

See detailed visual workflows: [Process Maps](docs/process-maps.md)
```

### **3. Reference in Documentation**

Link to specific diagrams:
```markdown
See the [Care Transition Workflow](docs/process-maps.md#2-care-transition-workflow-hospital-to-hospital)
```

### **4. Use in Presentations**

Take screenshots of rendered diagrams for PowerPoint/Google Slides.

### **5. Export as Images**

Use tools like:
- https://mermaid.live (paste diagram, export as PNG/SVG)
- GitHub's rendered view (screenshot)
- VS Code with Mermaid extension

---

## Diagram Legend

| Color | Meaning |
|-------|---------|
| Light Blue | User/Patient |
| Light Red | Events/Async |
| Light Green | AI/Processing |
| Light Purple | Audit/Ledger |
| Light Yellow | External Systems |
| Red | Urgent/Critical |
| Orange | Warning/Medium |
| Yellow | Notice/Low |
| Green | Success/Learning |

---

**These diagrams are ready to use in your Pitt-Anthropic submission!** 🎨

*Created: November 18, 2025*
