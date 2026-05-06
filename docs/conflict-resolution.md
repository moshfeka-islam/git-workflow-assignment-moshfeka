# Conflict Resolution Log

## Conflict Created: Task 4

### What Happened
Both `main` and `feature/add-staging-config` modified `app/config.yaml` at the same lines:
- `version` field
- `logging.level` field
- `timeout.request_timeout` field
- `environment` field

### Conflict Markers (Before Resolution)
```
service:
  name: platform-service
<<<<<<< HEAD
  version: "1.1.0"
=======
  version: "2.0.0"
>>>>>>> main
  port: 8080
  environment: staging

logging:
<<<<<<< HEAD
  level: debug
  format: json

timeout:
  request_timeout: 25
  idle_timeout: 60
=======
  level: warn
  format: json

timeout:
  request_timeout: 30
  idle_timeout: 90
>>>>>>> main
```

### Resolution Decision
| Field | `HEAD` (feature branch) | `main` | Resolution | Reason |
|-------|--------------------------|--------|------------|--------|
| `version` | `"1.1.0"` | `"2.0.0"` | `"2.0.0"` | Accept latest version from main |
| `environment` | `staging` | `production` | `staging` | Feature branch is for staging config |
| `logging.level` | `debug` | `warn` | `debug` | Staging uses debug logging for testing |
| `request_timeout` | `25` | `30` | `25` | Staging timeout value is correct here |

### Resolved File Content
```yaml
service:
  name: platform-service
  version: "2.0.0"
  port: 8080
  environment: staging

logging:
  level: debug
  format: json

timeout:
  request_timeout: 25
  idle_timeout: 60
```

### Commands Used
```bash
git checkout feature/add-staging-config
git merge main
# CONFLICT (content): Merge conflict in app/config.yaml
# Manually edited app/config.yaml to remove conflict markers
git add app/config.yaml
git commit -m "fix: resolve merge conflict — use v2.0.0 from main, keep staging env and debug logging"
```
