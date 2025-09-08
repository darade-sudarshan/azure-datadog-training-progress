# Voting App - Docker Compose Example

A sample voting application demonstrating microservices architecture with Docker Compose.

## Architecture

- **Vote Service** (Python/Flask) - Web interface for voting
- **Result Service** (Node.js/Express) - Web interface for viewing results  
- **Worker Service** (Python) - Background processor moving votes from Redis to PostgreSQL
- **Redis** - Message queue for votes
- **PostgreSQL** - Persistent storage for votes

## Services

| Service | Port | Technology | Purpose |
|---------|------|------------|---------|
| vote | 5000 | Python/Flask | Voting interface |
| result | 5001 | Node.js/Express | Results display |
| worker | - | Python | Vote processor |
| redis | - | Redis | Message queue |
| db | - | PostgreSQL | Data storage |

## Usage

```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f

# Scale vote service
docker compose up -d --scale vote=3

# Stop all services
docker compose down

# Stop and remove volumes
docker compose down -v
```

## Access

- **Voting Interface**: http://localhost:5000
- **Results Interface**: http://localhost:5001

## Network Architecture

- **front-tier**: Public-facing services (vote, result)
- **back-tier**: Internal services (worker, redis, db)