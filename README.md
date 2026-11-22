# Industrial Distribution Analytics Platform: Operations, Supply Chain & Working Capital

An end-to-end lifecycle data foundation and business intelligence platform built for industrial B2B distribution (machine tools components, carbide inserts, industrial adhesives, and MRO maintenance solutions). 

The platform models operations, addressing operational visibility challenges during distribution expansion from Java into Eastern Indonesia (Balikpapan and Makassar).

---

## 1. Business Context & Problems Solved

Industrial distributors supplying heavy manufacturing, automotive stampers, and mining contractors face specific supply chain and working capital constraints:
1. **Maritime Logistics & OTIF Slippage:** Java land deliveries arrive in 1 to 2 days with 94.8% On-Time In-Full (OTIF) compliance. Sea cargo shipments to Eastern Indonesia (Balikpapan/Makassar) require 8 to 18 days in transit, plunging regional OTIF to ~72% and stalling customer production lines.
2. **Working Capital Drag (AR Aging & DSO):** Regional fabricators and machine shops routinely exceed NET 30/60 terms, leaving 41% of outstanding receivables overdue (>IDR 12.9 Billion), with 48% of severe delinquency concentrated in Eastern branches.
3. **Consumable Replenishment Churn:** Machining inserts (CNMG, WNMG) and anaerobic adhesives are recurring consumables. When an account lapses past 1.5x its normal replacement cycle, it signals quiet defection to a rival tooling distributor.
4. **Dead Stock Traps (ABC-FSN):** Slow-moving tool holders and specialty lubricants tie up IDR 840 Million in stagnant working capital while fast-moving carbide inserts face stockout risks.

---

## 2. Architecture & Data Foundation

```
industrial-distribution-analytics/
├── data/                   # ERP transactional source dumps (Odoo / SAP schema)
│   ├── res_branch.csv        # 5 Regional branch warehouses
│   ├── product_template.csv  # 30 Industrial SKUs (Cutting Tools, Adhesives, MRO)
│   ├── res_partner.csv       # 350 Industrial accounts (Automotive, Mining, Fabrication)
│   ├── sale_order.csv        # 15,000 Order headers
│   ├── sale_order_line.csv   # 30,218 Order line items
│   ├── stock_picking.csv     # 15,000 Warehouse dispatch & delivery confirmations
│   └── account_invoice.csv   # 15,000 Billed invoices, terms, and collections
|    
├── src/
│   ├── ingestion/
│   ├── pipeline/
│   ├── sql/
│   ├── reports/
│   └── dashboard/
├── docs/
│   └── executive_brief_en.md     # Executive Decision Brief
├── tests/
├── reports/
└── requirements.txt
```

---

## 3. Quickstart & Verification

```bash
# 1. Activate environment
source .venv/bin/activate
```
