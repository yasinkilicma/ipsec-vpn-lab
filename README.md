# IPSec Site-to-Site VPN Lab — StrongSwan in Docker

Ein IPSec-VPN-Lab mit zwei StrongSwan-Endpunkten in Docker auf Alpine Linux. Entwickelt für das NSE4-Praktikum und die Vertiefung von IPSec-Protokollen (IKEv1, Phase 1/Phase 2, DPD, xfrm).

## Architektur

```
Site-A (Mannheim)        Docker-Netz            Site-B (Heidelberg)
10.0.1.0/24            10.255.0.0/24            10.0.2.0/24
     │                                                │
     │          IPSec Tunnel (ESP/AES-256)             │
     ├────────────────────────────────────────────────┤
     │                                                │
 10.0.1.1 (lo)                                  10.0.2.1 (lo)
 10.255.0.10 (eth0)                             10.255.0.20 (eth0)
```

## Projektstruktur

```
ipsec-vpn-lab/
├── docker-compose.yml       # Container-Definitionen
├── Dockerfile               # StrongSwan-Image (Alpine)
├── scripts/
│   └── entrypoint.sh        # Container-Startskript
├── site-a/
│   ├── ipsec.conf           # Site-A (Mannheim)
│   └── ipsec.secrets        # Pre-Shared Key
├── site-b/
│   ├── ipsec.conf           # Site-B (Heidelberg)
│   └── ipsec.secrets        # Pre-Shared Key
└── README.md
```

## Voraussetzungen

- **Docker** (Colima, Docker Desktop oder vergleichbar)
- **docker-compose** (Standalone oder als Docker-CLI-Plugin)
- ~1 GB freier Arbeitsspeicher

## Schnellstart

```bash
cd ipsec-vpn-lab
docker compose build
docker compose up -d
```

## Tunnel-Status prüfen

```bash
# IKE-SA und CHILD-SA anzeigen
docker exec ipsec-vpn-lab-site-a-1 ipsec statusall

# xfrm Security Association Database
docker exec ipsec-vpn-lab-site-a-1 ip xfrm state

# xfrm Security Policy Database
docker exec ipsec-vpn-lab-site-a-1 ip xfrm policy
```

## Verbindung testen

```bash
# Site-A → Site-B (Verschlüsselung über IPSec-Tunnel)
docker exec ipsec-vpn-lab-site-a-1 ping -c 4 -I 10.0.1.1 10.0.2.1

# Site-B → Site-A (Rückrichtung)
docker exec ipsec-vpn-lab-site-b-1 ping -c 4 -I 10.0.2.1 10.0.1.1
```

**Erwartetes Ergebnis:** 0 % Paketverlust, Latenz < 1 ms (Container-intern).

## Details der Konfiguration

| Parameter       | Wert                           |
|----------------|--------------------------------|
| Protokoll       | IKEv1 Main Mode                |
| Authentisierung | Pre-Shared Key                 |
| Phase 1         | AES-256-CBC / SHA-256 / DH-14  |
| Phase 2         | AES-256-CBC / SHA-256 / DH-14  |
| IKE-Lifetime    | 86 400 s (24 h)               |
| IPSec-Lifetime  | 3 600 s (1 h)                 |
| DPD             | 30 s Intervall, 120 s Timeout  |

## Debugging

```bash
# Live-Logs eines Containers
docker logs -f ipsec-vpn-lab-site-a-1

# IKE-Debug-Modus (Stufe 2: ike, knl, cfg)
# Ist in ipsec.conf gesetzt als: charondebug="ike 2, knl 2, cfg 2"
```

## Nächste Schritte

- [ ] **IKEv2** ergänzen (Migration von IKEv1)
- [ ] **Route-based VTI** statt Policy-based VPN
- [ ] **ADVPN** (Auto-Discovery VPN) mit mehreren Sites
- [ ] **SD-WAN / SLA-basiertes Routing**
- [ ] **Monitoring** mit FortiAnalyzer oder Prometheus

## Lizenz

Dieses Projekt dient ausschließlich Lernzwecken. StrongSwan steht unter der GPL v2.
