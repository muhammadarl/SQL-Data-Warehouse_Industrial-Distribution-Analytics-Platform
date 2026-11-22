# Executive Strategic & Technical Brief: SQL Data Warehouse Platform (Star Schema)
**Industrial Distribution Analytics: Operations, Supply Chain & Working Capital**

---

## 1. Executive Summary & Strategic Context

### 1.1 Business Background
In heavy industrial B2B distribution, operational excellence hinges on balancing fulfillment velocity against working capital exposure. This enterprise platform serves as the central data and decision-support infrastructure for an industrial distributor supplying mission-critical components—primarily **CNC carbide cutting inserts**, **industrial adhesives and sealants**, and **MRO (Maintenance, Repair, and Operations) maintenance supplies**—to automotive manufacturers, mining contractors, heavy equipment fabricators, and process plants across Indonesia.

```
       [ Java Central Distribution Centers ]
             (Cikarang & Surabaya)
                  │             │
        1-2 Day Transit    8-18 Day Maritime
         OTIF: ~67-70%       OTIF: ~47-48%
                  │             │
                  ▼             ▼
          [ Java Corridor ]   [ Eastern Expansion ]
         (Automotive & Tier)  (Balikpapan & Makassar)
                               - Mining / Nickel Smelters
                               - High AR Delinquency Risk
```

### 1.2 Core Business Dilemmas Addressed
As the enterprise scaled its distribution footprint from its historical Java manufacturing corridor into Eastern Indonesia (East Kalimantan and South Sulawesi), critical operational fractures emerged across four dimensions:

1. **Maritime Logistics & OTIF Collapse:**
   - **Java Core (Cikarang & Surabaya):** Deliveries operate via dedicated overland fleet and express regional trucking, achieving an average transit time of **1.4 days** and an On-Time In-Full (OTIF) rate of **~67%**.
   - **Eastern Expansion (Balikpapan & Makassar):** Relying on maritime freight and inter-island air cargo, transit times surge to **11.3 – 11.4 days** (total lead time ~13.0 days), driving OTIF down to **47.1% – 48.4%**. Unpredictable vessel schedules cause line-stoppages for mining and smelter clients.
2. **Working Capital Drag & Regional Accounts Receivable (AR) Delinquency:**
   - Out of **IDR 155.66 Billion** in total billed sales across 15,000 invoices, **IDR 4.95 Billion** remains outstanding, with **IDR 662.6 Million** severely overdue past standard credit terms (NET 30 / NET 60 / NET 90).
   - Regional exposure is heavily skewed: Eastern expansion hubs suffer from extreme overdue ratios—**24.6% of outstanding receivables in Makassar** and **18.3% in Balikpapan** are overdue, compared to only **7.6% in Surabaya** and **9.9% in Cikarang**. The Heavy Equipment & Mining Fabrication sector represents the single largest credit risk pool (**IDR 209.3 Million overdue**).
3. **Consumable Replenishment Churn (Silent Defection):**
   - Carbide cutting inserts (CNMG, WNMG, TNMG) and industrial threadlockers are recurring consumables with predictable burn rates. When an industrial machine shop’s replenishment interval lapses beyond **1.5x its historical purchase cadence**, it indicates production slowdown or defection to opportunistic local tool distributors.
4. **Inventory Allocation & Dead Stock vs. Stockout Exposure (ABC-FSN):**
   - High-value specialized tool holders and niche lubricants tie up substantial working capital as slow/non-moving stock, while high-velocity carbide inserts encounter frequent branch-level stockouts due to maritime replenishment latency.

### 1.3 Project Objective & Data Architecture Purpose
The purpose of this project is to construct a production-ready **Kimball Dimensional Data Warehouse (Star Schema)** that ingests raw, disparate transactional logs (Order Management, Warehouse Logistics, Invoicing, Customer, and Product Catalogs) and transforms them into high-performance analytical models. This architecture eliminates operational blind spots, empowers executive decision-makers with automated reporting, and provides the foundation for predictive inventory replenishment and credit risk mitigation.

---

## 2. Source Data Assessment & Ingestion Architecture

The operational foundation originates from an enterprise ERP system (Odoo / SAP data schema). The platform processes seven core relational tables containing 24 months of transactional data (2023–2024):

| Source Table / File | Entity Description | Record Count | Key Attributes & Business Grain |
| :--- | :--- | :--- | :--- |
| [`data/res_branch.csv`](file:///home/syiarul/projects/data-engineer/Industrial%20Distribution%20Analytics%20Platform:%20Operations,%20Supply%20Chain%20&%20Working%20Capital/data/res_branch.csv) | Regional Branch Warehouses | 5 branches | `branch_id`, `branch_name`, `region` (Java Core, Eastern Expansion, Sumatra), `province`, `sqm` capacity |
| [`data/product_template.csv`](file:///home/syiarul/projects/data-engineer/Industrial%20Distribution%20Analytics%20Platform:%20Operations,%20Supply%20Chain%20&%20Working%20Capital/data/product_template.csv) | Master Product Catalog | 30 SKUs | `product_id`, `sku_name`, `category` (Cutting Tools, Adhesives, MRO), `principal_origin`, `standard_cost_idr`, `list_price_idr`, `min_safety_stock` |
| [`data/res_partner.csv`](file:///home/syiarul/projects/data-engineer/Industrial%20Distribution%20Analytics%20Platform:%20Operations,%20Supply%20Chain%20&%20Working%20Capital/data/res_partner.csv) | Industrial B2B Accounts | 350 accounts | `customer_id`, `company_name`, `sector`, `city`, `province`, `region`, `assigned_branch_id`, `payment_terms`, `credit_limit_idr`, `account_status` |
| [`data/sale_order.csv`](file:///home/syiarul/projects/data-engineer/Industrial%20Distribution%20Analytics%20Platform:%20Operations,%20Supply%20Chain%20&%20Working%20Capital/data/sale_order.csv) | Sales Order Headers | 15,000 orders | `order_id`, `order_date`, `customer_id`, `branch_id`, `sales_rep_id`, `payment_terms`, `total_lines`, `order_total_idr`, `status` |
| [`data/sale_order_line.csv`](file:///home/syiarul/projects/data-engineer/Industrial%20Distribution%20Analytics%20Platform:%20Operations,%20Supply%20Chain%20&%20Working%20Capital/data/sale_order_line.csv) | Order Line Item Details | 30,218 line items | `line_id`, `order_id`, `product_id`, `qty_ordered`, `unit_price_idr`, `standard_cost_idr`, `discount_pct`, `subtotal_idr` |
| [`data/stock_picking.csv`](file:///home/syiarul/projects/data-engineer/Industrial%20Distribution%20Analytics%20Platform:%20Operations,%20Supply%20Chain%20&%20Working%20Capital/data/stock_picking.csv) | Warehouse Fulfillment & Delivery | 15,000 dispatches | `picking_id`, `order_id`, `scheduled_date`, `dispatch_date`, `delivered_date`, `warehouse_prep_days`, `transit_days`, `actual_lead_days`, `carrier_name`, `is_otif` |
| [`data/account_invoice.csv`](file:///home/syiarul/projects/data-engineer/Industrial%20Distribution%20Analytics%20Platform:%20Operations,%20Supply%20Chain%20&%20Working%20Capital/data/account_invoice.csv) | Invoicing & Collections | 15,000 invoices | `invoice_id`, `order_id`, `customer_id`, `invoice_date`, `due_date`, `paid_date`, `invoice_amount_idr`, `balance_outstanding_idr`, `aging_bucket` |

---

## 3. Conclusion

By transitioning from fragmented transactional ERP spreadsheets to a centralized **Kimball Star Schema Data Warehouse**, the enterprise establishes an institutional single source of truth. The platform directly resolves the operational blind spots that accompanied Eastern Indonesian expansion: **quantifying maritime fulfillment drag**, **isolating high-risk accounts receivable**, **preventing consumable customer defection**, and **releasing tied-up working capital**. This data-driven foundation equips executive leadership with the actionable clarity required to scale profitably and sustainably across the Indonesian archipelago.
