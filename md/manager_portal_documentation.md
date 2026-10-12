# 🥛 Vanthenda Paalkaran — Manager (Admin) Portal Comprehensive Documentation

> **Complete architectural blueprint, functional specifications, UI/UX structure, and data workflows for the Manager Portal in Vanthenda Paalkaran.**

---

## 📌 1. Overview & System Purpose

The **Manager (Admin) Portal** is the central command center for dairy milk vendors, distributors, and farm managers. It digitizes traditional pen-and-paper milk distribution (*paal kaaran chittai*) into a modern, real-time, zero-error management platform.

### Core Objectives:
1. **Eliminate Billing Discrepancies**: Replace paper cards with an immutable digital ledger of daily deliveries.
2. **Zero-Commission Direct Payments**: Enable direct UPI (GPay, PhonePe, Paytm, BHIM) and Cash-in-Hand collections without third-party aggregator commissions (e.g. Razorpay).
3. **Streamline Morning & Evening Deliveries**: Provide route-based dispatch, instant delivery logging, and extra milk handling.
4. **Automate Monthly Financial Reconciliations**: One-click monthly bill generation based on exact liters delivered and product tier pricing.
5. **Customer Relationship Management (CRM)**: Manage customer quotas, vacation pauses, and emergency requests in real time.

---

## 📁 2. File & Directory Structure

All files belonging to the Manager Portal are clustered under clean domain boundaries:

```
lib/features/manager_portal/
├── data/
│   ├── models/
│   │   └── demand_forecast.dart        # AI demand prediction model
│   └── repositories/
│       ├── customer_repository.dart    # Customer data layer & CRUD
│       ├── billing_repository.dart     # Monthly bills, invoices & payment logging
│       └── staff_repository.dart       # Delivery staff & route assignments
│
└── presentation/
    ├── providers/
    │   ├── customers_provider.dart     # Customer state notifier & search filters
    │   ├── billing_provider.dart       # Billing state, totals & generation notifier
    │   ├── staff_provider.dart         # Staff state notifier
    │   └── dashboard_provider.dart     # Dashboard metrics & aggregators
    │
    └── screens/
        ├── dashboard_screen.dart       # Manager Home Dashboard
        ├── customers_list_screen.dart  # Customer CRM & Directory
        ├── milk_card_screen.dart       # Daily Delivery Entry (Milk Card)
        ├── billing_dashboard_screen.dart # Monthly Billing & Invoices
        ├── payments_screen.dart        # Payment Collection & Reconciliations
        ├── milk_types_screen.dart      # Product Tier & Price per Liter Setup
        ├── staff_list_screen.dart      # Staff & Delivery Boy Management
        ├── vacation_mode_screen.dart   # Vacation & Delivery Pause Approvals
        ├── emergency_requests_screen.dart # Emergency & Extra Milk Requests
        ├── demand_forecast_screen.dart # AI Predictive Forecast for Tomorrow
        ├── ai_assistant_screen.dart    # Manager AI Operations Chatbot
        ├── settings_screen.dart        # Business, Language & Manager UPI Setup
        └── vendor_setup_screen.dart    # Initial Onboarding & Profile Setup
```

---

## 🎨 3. UI/UX & Design Architecture

The Manager Portal adheres to the **Antigravity Milkman Design System**:
- **Gradient Background**: Radial gradient mesh (`AppColors.gradientStart` to `AppColors.gradientEnd`) combined with the `pattern.svg` organic texture overlay.
- **Brand Elements**: Top squircle brand logo (`BorderRadius.circular(12)`) and blurred cow shadow (`ImageFilter.blur`).
- **Color Palette**:
  - `Primary` (`#1A56DB` / Deep Royal Blue): Brand identity & primary actions.
  - `Secondary` (`#10B981` / Emerald Green): Success, delivered status, and paid invoices.
  - `Warning` (`#F59E0B` / Amber Gold): Morning session indicators, pending approvals.
  - `Error` (`#EF4444` / Crimson): Overdue bills, rejected requests, delivery cancellations.
  - `Surface` (`#FFFFFF` / `#1E293B`): Clean elevated cards with subtle borders.
- **Navigation UX**:
  - Built with `GoRouter` using `context.push()` to preserve the history stack.
  - Sub-screens feature an explicit `leading: BackButton` fallback with `context.canPop() ? context.pop() : context.go(AppRoutes.dashboard)`.
  - Android gesture back and hardware back return smoothly to previous screens without crashing or dropping to the OS launcher.

---

## 🚀 4. Core Features & Functional Workflows

### 4.1. Manager Dashboard (`dashboard_screen.dart`)
- **Key Metrics Tiles**:
  - **Morning / Evening Targets**: Real-time progress bar (e.g. `45L / 120L delivered`).
  - **Today's Revenue**: Computed in real time from completed deliveries.
  - **Active Customers**: Count of currently subscribed households.
  - **Pending Deliveries**: Quick badge of unfulfilled routes.
- **Quick Action Grid**: One-tap access to Customer CRM, Milk Cards, Billing, Staff, Vacation Requests, Forecast, and AI Assistant.
- **Recent Deliveries List**: Live stream of today's morning and evening drops.

### 4.2. Customer CRM (`customers_list_screen.dart`)
- **Search & Filter**: Real-time instant search by customer name, phone number, or locality area (e.g., *Anna Nagar, T Nagar, Adyar*).
- **Default Session Quotas**: Each customer has configurable morning quota (e.g., `1.5L`) and evening quota (e.g., `0.5L`).
- **Product Type Association**: Customer is linked to their preferred milk type (*Cow, Buffalo, A2*).
- **Add / Edit Modal**: Bottom sheet modal with instant form validation.
- **Customer Lifecycle**: Mark active/inactive without losing historic delivery or billing records.

### 4.3. Daily Milk Card Engine (`milk_card_screen.dart`)
- Digital replacement of physical monthly milk cards.
- Allows manager or delivery boy to select customer, auto-fill default session quantity, and override liters or mark extra milk (*e.g., +1L for festival days*).
- Auto-calculates total price based on customer's milk type tier.

### 4.4. Monthly Billing & Invoices (`billing_dashboard_screen.dart`)
- **Automated Monthly Aggregation**: One-tap "Generate Bills" aggregates all 30 days of deliveries for each customer:
  $$\text{Total Amount} = \sum (\text{Liters Delivered} \times \text{Price per Liter})$$
- **Invoice Status Filtering**:
  - `All Bills`
  - `Unpaid / Overdue`
  - `Paid Invoices`
- **Reconciliation**: Real-time tracking of Total Billed vs. Total Collected vs. Total Outstanding.

### 4.5. Zero-Commission UPI & Cash Payment System (`payments_screen.dart` & `core/upi/`)
- **Admin Configuration**: Manager inputs their personal/business UPI ID (*e.g., `paalkaran@oksbi`*) and Payee Name in Settings.
- **Dynamic Customer QR Code**:
  - Automatically encodes the exact bill amount, customer invoice reference, and payee parameters into a standard UPI string:
    `upi://pay?pa=paalkaran@oksbi&pn=Vanthenda+Paalkaran&am=2250.00&cu=INR&tn=Milk+Bill+Aug`
- **Direct App Intent Launcher**: Customer can tap to open Google Pay, Paytm, PhonePe, or BHIM directly on their device with the amount pre-filled.
- **Cash in Hand Mode**: Manager can record manual cash payments with instant timestamping.

### 4.6. Milk Types & Pricing (`milk_types_screen.dart`)
- Manage product categories:
  - 🥛 **Pure Cow Milk**: Default tier (*₹50.00 / Liter*)
  - 🥛 **Fresh Buffalo Milk**: High-fat tier (*₹60.00 / Liter*)
  - 🥛 **Organic A2 Milk**: Premium tier (*₹75.00 / Liter*)
- Edit price per liter at any time with retroactive preservation of past deliveries.

### 4.7. Staff & Route Management (`staff_list_screen.dart`)
- Create accounts for delivery staff.
- Assign route boundaries and localities.
- View daily delivery completion stats per delivery boy.

### 4.8. Vacation Mode & Delivery Pause (`vacation_mode_screen.dart`)
- Customer submits vacation dates via customer portal (*e.g., Aug 20 to Aug 25*).
- Manager reviews pending requests with reason and dates.
- One-tap **Approve** or **Reject**:
  - Approved vacations automatically omit the customer from today's delivery route during that window, preventing wasted milk.

### 4.9. Emergency Requests (`emergency_requests_screen.dart`)
- Handles same-day emergency requests:
  - ➕ **Extra Milk**: Urgent requirement for guests/events.
  - ❌ **Day Cancellation**: Same-day cancellation.
- Manager marks request as **Resolved** with real-time UI status updates.

### 4.10. AI Demand Forecast & Assistant (`demand_forecast_screen.dart` & `ai_assistant_screen.dart`)
- **Tomorrow's Demand Prediction**: Forecasts exact morning and evening liter requirements based on past weekly consumption patterns, avoiding excess procurement or shortages.
- **Smart AI Chatbot**: Natural language queries (*"What is today's revenue?", "How many customers are active?", "Who has unpaid bills?"*).

---

## 💾 5. Dual Data Layer Architecture

The Manager Portal is designed with a **fail-safe dual architecture**:

```
┌────────────────────────────────────────────────────────┐
│                   MANAGER PORTAL UI                    │
└──────────────────────────┬─────────────────────────────┘
                           │
             ┌─────────────┴─────────────┐
             ▼                           ▼
 ┌───────────────────────┐   ┌───────────────────────────┐
 │   DEV MOCK MODE       │   │   PRODUCTION SUPABASE     │
 │   (MockDataStore)     │   │   (PostgreSQL + RLS)      │
 ├───────────────────────┤   ├───────────────────────────┤
 │ • 6 Demo Customers    │   │ • Secure Auth (auth.uid)  │
 │ • Real-time in-memory │   │ • PostgreSQL RPC & Tables │
 │ • Full CRUD testing   │   │ • Real-time row listeners │
 │ • Zero backend needed │   │ • Cloud Sync & Backups    │
 └───────────────────────┘   └───────────────────────────┘
```

1. **Development & Offline Simulation Mode** (`lib/core/database/mock_data.dart`):
   - Active when Supabase session is unauthenticated or during local dev.
   - Provides realistic datasets for immediate interactive testing across all screens without empty-state roadblocks.
2. **Production Mode** (Supabase PostgreSQL):
   - All production queries, RPC calls (`generate_monthly_bills`), and RLS filters are preserved cleanly in comments across all repositories.
   - Switchable instantly once live `.env` Supabase credentials and login are configured.

---

## 📋 6. Summary of Key Manager Routes

| Route Name | Route Constant | Description |
| :--- | :--- | :--- |
| `/dashboard` | `AppRoutes.dashboard` | Main Manager Command Dashboard |
| `/customers` | `AppRoutes.customers` | Customer Directory & CRM |
| `/milk-card` | `AppRoutes.milkCard` | Daily Delivery Entry |
| `/billing` | `AppRoutes.billing` | Monthly Billing Dashboard |
| `/payments` | `AppRoutes.payments` | Payment Collection & Records |
| `/milk-types` | `AppRoutes.milkTypes` | Product Types & Price/Liter |
| `/staff` | `AppRoutes.staff` | Delivery Staff & Route Setup |
| `/vacation-mode` | `AppRoutes.vacationMode` | Vacation Requests Approval |
| `/emergency-requests` | `AppRoutes.emergencyRequests`| Extra Milk & Emergency Logs |
| `/demand-forecast` | `AppRoutes.demandForecast` | AI Predictive Delivery Forecasting |
| `/ai-assistant` | `AppRoutes.aiAssistant` | AI Assistant Bot |
| `/settings` | `AppRoutes.settings` | Business & UPI QR Configuration |

---

*Document created and maintained for the **Vanthenda Paalkaran** project.*
