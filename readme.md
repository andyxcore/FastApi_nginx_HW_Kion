## Example for zero-downtime deploys with nginx and docker-compose

### Based on FastApi services and nginx as a load balancer

#### Usage:
    1. Set the scale_factor in release_script.sh to the value u want
    2. cd directory where this repo is located
    3. run docker compose up
    4. after changes in service (./app/app.py) run ./release_script.sh
