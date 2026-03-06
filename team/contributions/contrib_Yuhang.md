# Code Contributions – Yuhang Jiang

## Database Management
- Implmeneted the whole database program `db_manager.py` storing necessary user's info with fetching and updating functions ([70abd18](../../backend/database/db_manager.py))
- Fixed path resolving issue of the database storage file, and move the path under `.env` to protect privacy ([70abd18](../../backend/database/db_manager.py))

## Production Server Setup & Maintenance
- Built and run the service app on the production server
- Migrated the localhost url to the actual production server on the Google Cloud Console
- Setup TLS certificates and Proxy to make `https://cs148.misc.iamjiamingliu.com/cs148api` usable

## Auto-deployment Script
- Updated the script `CD.yaml` that github action would automatically login into the server, synchronize with main, and restart the server ([57feb28](../../.github/workflows/CD.yaml))

## Database Testing
- Wrote backend database tests (`backend/tests/test_db_manager.py`) – 121 lines covering valid/invalid parameters for fetching and updating funtions, also mocking the connection erros ([b831e40](../../backend/tests/test_db_manager.py))
- Documented component testing approach in `team/TESTING.md`([54809f9](../../team/TESTING.md)) 

## Deployment Documentation
- Updated the deployment procedures in the `readme.md` ([00c63d6](../../README.md))
- Created a detailed and live documentation on deployment procedures in `DEPLOY.md` ([18a07a5](../../docs/DEPLOY.md))
