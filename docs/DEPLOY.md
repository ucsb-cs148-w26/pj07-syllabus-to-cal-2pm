# Deployment & Environment Guide

ThiS **LIVE** document outlines the deployment architecture, system dependencies, and environment setup instructions for the Plannr iOS application and its accompanying backend API.

## 1. System Architecture & Deployment

### iOS Application (Frontend)

The Plannr iOS client is a native application built entirely with Apple frameworks (SwiftUI, AuthenticationServices, UniformTypeIdentifiers). It requires no third-party package managers (like CocoaPods or SPM) for external dependencies. It is compiled and run via Xcode for both physical devices and simulators.

### Python Backend (API)

The backend is a RESTful API built with FastAPI.

* **Production Server:** The API is deployed to a remote Bitnami server and is publicly accessible at: `https://cs148.misc.iamjiamingliu.com/cs148api/`
* **Continuous Deployment (CD):** Deployment is fully automated via GitHub Actions.

> **Deployment Workflow:** On every push to the `main` branch, the `.github/workflows/CD.yaml` workflow triggers. The runner SSHs into the production server, fetches the latest source code, installs/updates dependencies, and automatically restarts the `plannr` systemd service.

#### CI/CD Required Secrets

For the GitHub Actions deployment pipeline to function successfully, the following repository variables and secrets must be configured in GitHub:

| Variable/Secret Name | Type | Description |
| --- | --- | --- |
| `SSH_HOST` | Repository Variable | The hostname or IP of the remote Bitnami server. |
| `SSH_USERNAME` | Repository Variable | The SSH username for server access. |
| `SSH_KEY` | Repository Secret | The SSH private key corresponding to the server's authorized keys. |

---

## 2. Prerequisites & Integrations

Ensure your local development environment meets the following requirements before proceeding with installation:

* **Apple Ecosystem:** Xcode 15+ (includes iOS 17+ SDK)
* **Python Environment:** Python 3.10+ and `pip`
* **Version Control:** Git
* **Google Cloud Console:** A configured GCP Project with the following enabled:
* Google Calendar API
* Google OAuth 2.0 (Client ID & Secret)
* Gemini API (Google Generative AI)

You may check `\backend\requirements.txt` for a detailed dependencies requirements and versionings.

---

## 3. Local Installation & Setup

Depending on your development goals, choose one of the following setup paths.

### Option A: Client-Only Setup (Recommended)

*Use this method if you are strictly working on the iOS UI/UX and want to consume the live production API.*

1. **Clone the repository:**
```bash
git clone https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm.git
cd pj07-syllabus-to-cal-2pm

```


2. **Launch the project:**
```bash
open Plannr/Plannr.xcodeproj

```


3. **Build and Run:** Select your target device or simulator in Xcode and press `Cmd + R`.

### Option B: Full-Stack Local Development

*Use this method if you are actively developing backend features, altering API responses, or debugging server logic.*

#### Part 1: Backend Setup

1. **Clone the repository and navigate to the backend:**
```bash
git clone https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm.git
cd pj07-syllabus-to-cal-2pm/backend

```


2. **Initialize the virtual environment and install dependencies:**
```bash
python3 -m venv venv
source venv/bin/activate    # Windows: venv\Scripts\activate
pip install -r requirements.txt

```


3. **Configure Environment Variables:**
```bash
cp .env.SAMPLE .env

```


Open the newly created `.env` file and populate your specific API keys:
* `GEMINI_API_KEY`: Your Google Gemini API key
* `GOOGLE_CLIENT_ID`: Your Google OAuth client ID
* `GOOGLE_CLIENT_SECRET`: Your Google OAuth client secret
* `GOOGLE_REDIRECT_URI`: Must be set to `http://localhost:8000/auth/callback`
* (optional) `DB_FILEPATH`: Add this variable and set to the filepath storing your own database file, or don't add it to use the default database file `\backend\database\SAMPLE.db`


4. **Start the local server:**
```bash
uvicorn app:app --host 0.0.0.0 --port 8000 --reload

```



#### Part 2: Pointing the iOS App to Localhost

Before running the app, you must redirect the network calls from the production server to your local machine.

1. **Update `AuthManager.swift`:**
Locate the `backendURL` variable in `Plannr/Plannr/AuthManager.swift` and update it:
```swift
// Change from production URL to:
private let backendURL = "http://localhost:8000"

```


2. **Update `PDFUploadView.swift`:**
Locate the `BACKEND_URL` constant in `Plannr/Plannr/PDFUploadView.swift` and update it:
```swift
// Change from production URL to:
let BACKEND_URL = "http://localhost:8000"

```


3. **Launch the iOS app:**
Open `Plannr/Plannr.xcodeproj` in Xcode and press `Cmd + R`.

---

## 4. Troubleshooting
coming soon
