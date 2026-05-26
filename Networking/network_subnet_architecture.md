# Corporate Subnet Architecture Specification

This repository contains the network design, allocation tables, and security guardrails for our corporate cloud infrastructure. The architecture is engineered to isolate production data workloads while maintaining a highly secure, routed public ingress tier.

## Architectural Overview

```text
               [ Public Internet ]
                        │
                        ▼ (Port 80/443)
       ┌─────────────────────────────────┐
       │     Public-DMZ-01 Subnet        │
       │       (172.16.1.0/24)           │
       │  [ Nginx / Web Frontends ]      │
       └────────────────┬────────────────┘
                        │
                        ▼ (Layer 3 Routed Gateway)
       ┌─────────────────────────────────┐
       │     Private-DB-02 Subnet        │
       │       (172.16.2.0/24)           │
       │   [ Production Databases ]      │
       └─────────────────────────────────┘
```

---

## Network Allocation Table

* **Base Supernet Range:** 172.16.0.0/16


| Subnet Tier Name | Intended Workload | CIDR Block Assigned | Usable IP Range | Max Usable Hosts | Internet Accessibility |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Public-DMZ-01** | Web Frontends / Nginx | `172.16.1.0/24` | `172.16.1.1 - 172.16.1.254` | 254 | **Direct Public Inbound** |
| **Private-DB-02** | Production Databases  | `172.16.2.0/24` | `172.16.2.1 - 172.16.2.254` | 254 | **Isolated (Internal Only)** |

---

## Architectural

### Case Scenario A: Cross-Subnet Communication
* **The Question I Looked At:** If an application server living on IP 172.16.1.15 needs to pull a dataset from the database cluster at 172.16.2.50, can they talk directly at Layer 2, or do I need a router to step in?
* **My Engineering Verdict:** Direct Layer 2 communication will not work here. Because the network prefixes are completely different (172.16.1.0 vs 172.16.2.0), the source machine immediately flags the destination as an outside address. To make this connection happen, I configured the application server to hand the traffic over to its local gateway router on the Public-DMZ-01 side. That router then processes the packet, checks its routing tables, and safely hands it across the Layer 3 boundary over to the Private-DB-02 subnet interface.

### Case Scenario B: The Internet Isolation Guarantee
* **The Question I Looked At:** How do I structurally guarantee that an external attacker scanning the public internet cannot drop a packet directly onto our database server at 172.16.2.50?
* **My Engineering Verdict:** I rely on a strict, two-layer defense-in-depth approach to lock this down:
    1. **Zero Internet Routing:** I have completely stripped the Internet Gateway route (0.0.0.0/0 -> igw) from the Private Subnet’s routing table. Without this path, the public internet physically cannot map a route into this network.
    2. **Strict Firewall Boundaries:** I enforce Layer 4 Network ACLs on the private subnet that automatically drop all inbound public traffic. The firewall only drops its guard for incoming packets that explicitly match our internal 172.16.1.0/24 frontend server block.



