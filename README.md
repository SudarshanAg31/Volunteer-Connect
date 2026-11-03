Volunteer Connect — Volunteer & NGO Operations Platform
Volunteer Connect is a full-stack mobile application that connects volunteers with NGOs and social organizations. It centralizes opportunity discovery, applications, approvals, role-based dashboards, and administrative workflows in one protected workspace.

Live API: volunteer-connect-backend-4d55.onrender.com

API Base: /api/

Health check: /api/opportunities/

Admin panel: /admin/

This application is an academic full-stack project. Authentication is intentionally simple (plain-text credentials for demonstration), and the deployment is hosted on free-tier infrastructure. It should not be presented as production-grade authentication without further hardening.

Table of contents
Overview

Objectives

Implemented features

Roles and permissions

Technology stack

System architecture

Project structure

Authentication and authorization

Data model and relationships

API reference

Local setup

Environment variables

Development commands

Deployment

Security measures

Screenshots

Future improvements

Troubleshooting

Author

Overview
Volunteers often struggle to find legitimate opportunities, and NGOs often struggle to manage volunteer applications without a dedicated platform. Volunteer Connect bridges that gap with a shared, role-aware workspace.

The Flutter client uses Provider for state management and a reusable ApiService for all HTTP/JSON calls. The Django backend owns validation, role checks, relationship integrity, application status transitions, and administrative actions. The database is a Neon PostgreSQL instance accessed exclusively through Django ORM.

Objectives
Provide a single, focused platform for volunteer opportunity discovery.

Keep volunteer, NGO, and admin operations behind server-side role authorization.

Maintain consistent relationships between users, opportunities, and applications.

Prevent duplicate applications and invalid status transitions.

Deliver a mobile-first experience that is simple, clean, and functional.

Implemented features
Public registration for volunteer and NGO accounts; admin accounts are provisioned separately.

Email/password login with session persistence via SharedPreferences.

Splash screen with role-aware routing.

Volunteer dashboard with search, category filters, and opportunity cards.

Opportunity details screen with apply action and duplicate-application prevention.

"My Activities" screen listing the authenticated volunteer's applications with status badges and cancellation support.

Profile screen with editable name/phone and logout flow.

Admin/NGO dashboard with opportunity CRUD via modal forms (no separate screens).

Applicant review dialog with approve/reject/review status updates.

Search across title, description, NGO name, and location.

Category filtering using predefined choices.

Django admin panel integration for all three models.

Optional location coordinates on opportunities (map display is optional; text fallback provided).

Data seeding via a custom management command (seed_data).

Automatic superuser provisioning on deployment via a custom management command (create_admin).

Production static file handling via Whitenoise.

CORS configuration for the Flutter client.

Environment-driven configuration for database and secret key.

Idempotent deployment build script.

Roles and permissions
Role	Access summary
Volunteer	Browse and search opportunities, filter by category, view details, apply for opportunities, view their own applications, cancel applications, update their profile.
NGO	All volunteer read operations, plus opportunity CRUD scoped to their own listings and applicant review for their own opportunities.
Admin	Full operational access: opportunity CRUD across all records, applicant review, application status management, and Django admin panel access.
The backend is authoritative for authorization. Flutter UI controls are for user experience only and are not treated as security boundaries.

Technology stack
Frontend
Flutter 3.x

Dart 3.x

Provider 6.1.1

http 1.1.0

shared_preferences 2.2.2

image_picker 1.0.5

intl 0.18.1

Material 3 design system

Backend
Python 3.10.11

Django 4.2.7

Gunicorn 21.2.0

Whitenoise 6.6.0

django-cors-headers 4.3.0

psycopg2-binary 2.9.9

dj-database-url 2.1.0

python-decouple 3.8

Database and hosting
Neon PostgreSQL (serverless)

Render deployment for the Django API

Render static file serving via Whitenoise

GitHub for source control and CI-style deployment trigger

System architecture
Flutter mobile client
│ HTTP / JSON
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

The Django backend connects to Neon PostgreSQL at startup. Static files are collected during the build step and served by Whitenoise. The Flutter app communicates exclusively through HTTP/JSON endpoints under /api/.

Project structure
volunteer_connect/
├── backend/
│ ├── manage.py
│ ├── requirements.txt
│ ├── build.sh
│ ├── runtime.txt
│ ├── render.yaml
│ ├── .env.example
│ ├── volunteer_connect/
│ │ ├── settings.py
│ │ ├── urls.py
│ │ ├── wsgi.py
│ │ └── asgi.py
│ └── api/
│ ├── admin.py
│ ├── apps.py
│ ├── models.py
│ ├── urls.py
│ ├── views.py
│ ├── migrations/
│ └── management/
│ └── commands/
│ ├── seed_data.py
│ └── create_admin.py
│
└── volunteer_connect/
├── lib/
│ ├── main.dart
│ ├── models/
│ │ ├── user.dart
│ │ ├── opportunity.dart
│ │ └── application.dart
│ ├── providers/
│ │ ├── auth_provider.dart
│ │ ├── opportunity_provider.dart
│ │ └── application_provider.dart
│ ├── screens/
│ │ ├── splash_screen.dart
│ │ ├── login_screen.dart
│ │ ├── register_screen.dart
│ │ ├── volunteer_home_screen.dart
│ │ ├── opportunity_details_screen.dart
│ │ ├── my_activities_screen.dart
│ │ ├── profile_screen.dart
│ │ └── admin_dashboard_screen.dart
│ ├── services/
│ │ ├── api_service.dart
│ │ └── shared_pref_service.dart
│ ├── utils/
│ │ ├── api_constants.dart
│ │ ├── app_theme.dart
│ │ └── validators.dart
│ └── widgets/
│ ├── opportunity_card.dart
│ ├── application_card.dart
│ └── loading_widget.dart
├── android/
├── ios/
├── test/
├── pubspec.yaml
└── README.md

Authentication and authorization
POST /api/login/ validates email and password, then returns a safe user object (never the password).

The Flutter client stores the user session in SharedPreferences for persistence.

The client attaches the user's role and (when relevant) email to protected operations that require ownership checks.

The backend enforces role rules in every relevant view.

NGO operations are scoped by created_by_email so one NGO cannot manage another NGO's listings.

Admin operations are gated by the admin role and are additionally protected by the Django admin panel.

This is an academic authentication model. Passwords are not hashed in this project by design for simplicity. Do not reuse this authentication model in production.

Data model and relationships
Model	Important fields and relationships
User	name, email (unique), phone, password, role (volunteer / admin / ngo), optional profile_image.
Opportunity	title, description, ngo_name, category, location, optional latitude/longitude, date, time, volunteers_required, created_at, optional created_by_email linking it to an NGO user.
Application	Required user and opportunity references with a unique constraint on the pair. status in {Applied, Approved, Rejected, Cancelled}. applied_date recorded automatically.
Relationship integrity is enforced by the API for new applications. Duplicate applications are rejected at both the API and ORM level.

API reference
All routes below are relative to https://volunteer-connect-backend-4d55.onrender.com. Successful responses generally use { "success": true, "message": "...", "data": ... }; failures use { "success": false, "message": "..." }.

Public authentication
Method	Endpoint	Description
POST	/api/register/	Register a Volunteer or NGO account. Admin registration is rejected.
POST	/api/login/	Authenticate and receive a safe user object.
Users
Method	Endpoint	Description
GET	/api/users/{id}/	Retrieve a user profile.
PUT	/api/users/{id}/	Update name, phone, or profile image. Role changes are not permitted.
Opportunities
Method	Endpoint	Description
GET	/api/opportunities/	List opportunities with optional search, category, role, and email filters.
GET	/api/opportunities/{id}/	Retrieve a single opportunity.
POST	/api/opportunities/	Create an opportunity. Admin or NGO.
PUT	/api/opportunities/{id}/	Update an opportunity. Admin or owning NGO.
DELETE	/api/opportunities/{id}/	Delete an opportunity. Admin or owning NGO.
GET	/api/opportunities/{id}/applicants/	List applicants for an opportunity. Admin or owning NGO.
Query parameters for GET /api/opportunities/:

?search=<term> — matches title, description, NGO name, and location.

?category=<name> — matches one of the predefined categories.

?role=ngo&email=<email> — scopes results to a single NGO.

Applications
Method	Endpoint	Description
POST	/api/applications/	Apply for an opportunity. Duplicate applications are rejected.
GET	/api/applications/user/{user_id}/	List the authenticated user's applications with status and opportunity details.
DELETE	/api/applications/{id}/	Cancel an application. Approved applications cannot be cancelled.
PUT	/api/applications/{id}/status/	Update application status. Admin or owning NGO only.
Admin utilities
Method	Endpoint	Description
GET	/api/admin/dashboard/	Operational overview counts. Admin only.
GET	/api/admin/applications/	Full application list for administrative review. Admin only.
Local setup
Prerequisites
Python 3.10 or later

Flutter 3.x or later

A Neon PostgreSQL database (or local PostgreSQL)

Git

Backend install
cd backend
python -m venv venv

Windows
venv\Scripts\activate

macOS / Linux
source venv/bin/activate

pip install -r requirements.txt

Configure the API
Create backend/.env with local values. Never commit this file.

DATABASE_URL=postgresql://user:password@host/dbname?sslmode=require
SECRET_KEY=replace-with-a-strong-secret
DEBUG=True

Run backend migrations
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
python manage.py seed_data # optional
python manage.py runserver

The API will be available at http://127.0.0.1:8000/.

Flutter app install
cd volunteer_connect
flutter pub get

Update lib/utils/api_constants.dart with the backend base URL you want to target:

static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
static const String baseUrl = 'http://192.168.1.100:8000/api'; // Physical device
static const String baseUrl = 'https://volunteer-connect-backend-4d55.onrender.com/api'; // Production

Run the app:

flutter run

Build a release APK:

flutter build apk --release

Environment variables
backend/.env
Variable	Description
DATABASE_URL	Neon PostgreSQL connection string with sslmode=require. Required for production.
SECRET_KEY	Django secret key. Required for production.
DEBUG	Set to False in production.
PYTHON_VERSION	Used by Render; pinned to 3.10.11.
DJANGO_SUPERUSER_USERNAME	Optional; used by create_admin on deploy.
DJANGO_SUPERUSER_EMAIL	Optional; used by create_admin on deploy.
DJANGO_SUPERUSER_PASSWORD	Optional; used by create_admin on deploy.
Do not expose these values in client code, logs, or the repository.

Development commands
From the repository root or the backend/ folder:

Backend
python manage.py runserver
python manage.py makemigrations
python manage.py migrate
python manage.py seed_data
python manage.py create_admin

Flutter
flutter run
flutter build apk --release
flutter clean
flutter pub get

Deployment
The published deployment uses Render for the Django backend and Neon for PostgreSQL.

For a production deployment:

Create a Neon PostgreSQL database and copy the connection string.

Deploy the backend/ folder as a Python web service on Render.

Set the required environment variables on Render:

DATABASE_URL

SECRET_KEY

DEBUG=False

PYTHON_VERSION=3.10.11

Set the build command to ./build.sh.

Set the start command to gunicorn backend.wsgi:application.

Confirm GET /api/opportunities/ returns JSON after deployment.

Verify /admin/ loads correctly and superuser login succeeds.

Update lib/utils/api_constants.dart in the Flutter app to point at the deployed URL and rebuild the APK.

The build.sh script installs dependencies, collects static files, applies migrations, and can provision a superuser idempotently.

Security measures
Role-aware authorization for NGO and admin operations.

NGO ownership checks for opportunity update, delete, and applicant review.

Unique constraint on (user, opportunity) to prevent duplicate applications.

Protection against cancelling an approved application.

Server-side validation for required fields, valid email format, and non-empty password.

Environment-driven CORS configuration.

Whitenoise static file serving for admin assets.

Django admin panel for operational oversight.

No passwords are returned in API responses.

Flutter stores only non-sensitive session metadata in SharedPreferences.

.env files are excluded from source control.

This is an academic implementation. Passwords are not hashed, sessions are not cryptographically signed, and tokens are not issued. For production, switch to hashed passwords (e.g., Django auth users), add token-based sessions, and enforce HTTPS-only cookies or bearer tokens.

Screenshots
Screenshots are not included in this repository yet. Suggested captures for a future documentation update:

docs/screenshots/splash.png
docs/screenshots/login.png
docs/screenshots/register.png
docs/screenshots/volunteer-home.png
docs/screenshots/opportunity-details.png
docs/screenshots/my-activities.png
docs/screenshots/profile.png
docs/screenshots/admin-dashboard.png

Future improvements
These are intentionally future-facing and are not claims about the current implementation:

Hashed passwords using Django's auth system.

Token-based session management with refresh and revocation.

Server-side pagination for large opportunity and application lists.

Push notifications for application status changes.

Profile image upload with a managed storage backend.

Structured audit logging for administrative actions.

Rate limiting for login and registration endpoints.

Automated backend tests for all CRUD flows.

Automated Flutter widget and integration tests.

Advanced search ranking and saved searches for volunteers.

Troubleshooting
Backend returns 500 on admin pages
Ensure staticfiles are collected during build (python manage.py collectstatic --no-input).

Confirm STATICFILES_STORAGE is set to whitenoise.storage.CompressedStaticFilesStorage.

Confirm WhitenoiseMiddleware is installed directly after SecurityMiddleware.

Backend returns DisallowedHost
Add the deployed domain to ALLOWED_HOSTS and CSRF_TRUSTED_ORIGINS.

Database connection fails
Confirm DATABASE_URL is present in the environment.

Confirm the Neon project is active (free tier suspends after inactivity).

Confirm sslmode=require is present in the connection string.

App shows a network error or times out
Confirm the deployed backend is reachable in a phone browser.

Confirm baseUrl in lib/utils/api_constants.dart matches the deployed URL exactly and includes /api.

Confirm the device has internet access.

Free-tier Render services sleep after inactivity; the first request may take 30–60 seconds.

Login or registration works but data is not visible in admin
Confirm migrations were applied to the same database used by the deployed backend.

Confirm the backend was not restarted between migrations and testing.

Confirm seed_data was run if expected sample data is missing.

APK build fails with Kotlin incremental cache errors
Add kotlin.incremental=false to android/gradle.properties.

Run flutter clean and rebuild.

Move PUB_CACHE to the same drive as the Flutter project to avoid cross-drive cache issues.

Author
Sudarshan Agrawal

GitHub: @SudarshanAg31

Repository: Volunteer_Connect_Backend
