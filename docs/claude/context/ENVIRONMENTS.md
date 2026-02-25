# Environments

> Last updated: {{DATE}}

## Development

| Service | URL | Port |
|---------|-----|------|
| Backend | http://localhost:{{DEV_PORT_BACKEND}} | {{DEV_PORT_BACKEND}} |
| Frontend | {{LOCAL_URL}} | {{DEV_PORT_FRONTEND}} |

### Start Dev Servers
```bash
# Backend
{{DEV_SERVER_BACKEND}}

# Frontend
{{DEV_SERVER_FRONTEND}}
```

### Environment Variables

<!-- List required environment variables -->
<!-- Example:
| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | Database connection string | `sqlite:///data.db` |
| `JWT_SECRET` | JWT signing key | Auto-generated |
-->

## Production

| Service | URL |
|---------|-----|
| Application | {{PROD_URL}} |

### Deployment
```bash
{{DEPLOY_COMMAND}}
```

### Health Check
```bash
{{HEALTH_CHECK_COMMAND}}
```

## Differences Between Environments

<!-- Document key differences (e.g., debug mode, CORS, logging levels) -->
