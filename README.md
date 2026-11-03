# Volunteer Connect — Volunteer & NGO Operations Platform

Volunteer Connect is a full-stack mobile application that connects volunteers with NGOs and social organizations. It centralizes opportunity discovery, applications, approvals, role-based dashboards, and administrative workflows in one protected workspace.

> This application is an academic full-stack project. Authentication is intentionally simple (plain-text credentials for demonstration), and the deployment is hosted on free-tier infrastructure. It should not be presented as production-grade authentication without further hardening.

## Table of contents

- [Overview](#overview)
- [Objectives](#objectives)
- [Implemented features](#implemented-features)
- [Roles and permissions](#roles-and-permissions)
- [Technology stack](#technology-stack)
- [System architecture](#system-architecture)
- [Project structure](#project-structure)
- [Authentication and authorization](#authentication-and-authorization)
- [Data model and relationships](#data-model-and-relationships)
- [API reference](#api-reference)
- [Local setup](#local-setup)
- [Environment variables](#environment-variables)
- [Development commands](#development-commands)
- [Deployment](#deployment)
- [Security measures](#security-measures)
- [Screenshots](#screenshots)
- [Future improvements](#future-improvements)
- [Troubleshooting](#troubleshooting)
- [Author](#author)

## Overview

Volunteers often struggle to find legitimate opportunities, and NGOs often struggle to manage volunteer applications without a dedicated platform. Volunteer Connect bridges that gap with a shared, role-aware workspace.

The Flutter client uses Provider for state management and a reusable `ApiService` for all HTTP/JSON calls. The Django backend owns validation, role checks, relationship integrity, application status transitions, and administrative actions. The database is a Neon PostgreSQL instance accessed exclusively through Django ORM.

## Objectives

- Provide a single, focused platform for volunteer opportunity discovery.
- Keep volunteer, NGO, and admin operations behind server-side role authorization.
- Maintain consistent relationships between users, opportunities, and applications.
- Prevent duplicate applications and invalid status transitions.
- Deliver a mobile-first experience that is simple, clean, and functional.

## Implemented features

- Public registration for volunteer and NGO accounts; admin accounts are provisioned separately.
- Email/password login with session persistence via `SharedPreferences`.
- Splash screen with role-aware routing.
- Volunteer dashboard with search, category filters, and opportunity cards.
- Opportunity details screen with apply action and duplicate-application prevention.
- "My Activities" screen listing the authenticated volunteer's applications with status badges and cancellation support.
- Profile screen with editable name/phone and logout flow.
- Admin/NGO dashboard with opportunity CRUD via modal forms (no separate screens).
- Applicant review dialog with approve/reject/review status updates.
- Search across title, description, NGO name, and location.
- Category filtering using predefined choices.
- Django admin panel integration for all three models.
- Optional location coordinates on opportunities (map display is optional; text fallback provided).
- Data seeding via a custom management command (`seed_data`).
- Automatic superuser provisioning on deployment via a custom management command (`create_admin`).
- Production static file handling via Whitenoise.
- CORS configuration for the Flutter client.
- Environment-driven configuration for database and secret key.
- Idempotent deployment build script.

## Roles and permissions

| Role | Access summary |
| --- | --- |
| **Volunteer** | Browse and search opportunities, filter by category, view details, apply for opportunities, view their own applications, cancel applications, update their profile. |
| **NGO** | All volunteer read operations, plus opportunity CRUD scoped to their own listings and applicant review for their own opportunities. |
| **Admin** | Full operational access: opportunity CRUD across all records, applicant review, application status management, and Django admin panel access. |

The backend is authoritative for authorization. Flutter UI controls are for user experience only and are not treated as security boundaries.

## Technology stack

### Frontend

- Flutter 3.x
- Dart 3.x
- Provider 6.1.1
- http 1.1.0
- shared_preferences 2.2.2
- image_picker 1.0.5
- intl 0.18.1
- Material 3 design system

### Backend

- Python 3.10.11
- Django 4.2.7
- Gunicorn 21.2.0
- Whitenoise 6.6.0
- django-cors-headers 4.3.0
- psycopg2-binary 2.9.9
- dj-database-url 2.1.0
- python-decouple 3.8

### Database and hosting

- Neon PostgreSQL (serverless)
- Render deployment for the Django API
- Render static file serving via Whitenoise
- GitHub for source control and CI-style deployment trigger

## System architecture

```text
Flutter mobile client
        │  HTTP / JSON
        ▼
Django REST-style API (JsonResponse)
        │
        ├── URL routing
        ├── Function-based views
        ├── Role and relationship validation
        ├── Django ORM models
        └── Management commands (seed_data, create_admin)
                │
                ▼
         Neon PostgreSQL
```
<h3>Project structure<h3>
  
```text
volunteer_connect/
├── backend/
│   ├── manage.py
│   ├── requirements.txt
│   ├── build.sh
│   ├── runtime.txt
│   ├── render.yaml
│   ├── .env.example
│   ├── volunteer_connect/
│   │   ├── settings.py
│   │   ├── urls.py
│   │   ├── wsgi.py
│   │   └── asgi.py
│   └── api/
│       ├── admin.py
│       ├── apps.py
│       ├── models.py
│       ├── urls.py
│       ├── views.py
│       ├── migrations/
│       └── management/
│           └── commands/
│               ├── seed_data.py
│               └── create_admin.py
│
└── volunteer_connect/
    ├── lib/
    │   ├── main.dart
    │   ├── models/
    │   │   ├── user.dart
    │   │   ├── opportunity.dart
    │   │   └── application.dart
    │   ├── providers/
    │   │   ├── auth_provider.dart
    │   │   ├── opportunity_provider.dart
    │   │   └── application_provider.dart
    │   ├── screens/
    │   │   ├── splash_screen.dart
    │   │   ├── login_screen.dart
    │   │   ├── register_screen.dart
    │   │   ├── volunteer_home_screen.dart
    │   │   ├── opportunity_details_screen.dart
    │   │   ├── my_activities_screen.dart
    │   │   ├── profile_screen.dart
    │   │   └── admin_dashboard_screen.dart
    │   ├── services/
    │   │   ├── api_service.dart
    │   │   └── shared_pref_service.dart
    │   ├── utils/
    │   │   ├── api_constants.dart
    │   │   ├── app_theme.dart
    │   │   └── validators.dart
    │   └── widgets/
    │       ├── opportunity_card.dart
    │       ├── application_card.dart
    │       └── loading_widget.dart
    ├── android/
    ├── ios/
    ├── test/
    ├── pubspec.yaml
    └── README.md
```

