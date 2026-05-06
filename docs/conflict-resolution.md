# Conflict Resolution Log

## Conflict Created: Task 4

### What Happened
Both `main` and `feature/add-staging-config` modified `app/config.yaml` at the same lines:
- `version` field
- `logging.level` field
- `timeout.request_timeout` field
- `environment` field

### Conflict Markers (Before Resolution)
<img width="773" height="473" alt="Conflict" src="https://github.com/user-attachments/assets/282ef907-4fb8-47ae-90ee-f62c4261d299" />




<img width="1007" height="197" alt="Conflict create" src="https://github.com/user-attachments/assets/5eaee4e0-b602-401f-b55d-704966f291c3" />


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

**PR:** https://github.com/moshfeka-islam/git-workflow-assignment-moshfeka/pull/1

<img width="1297" height="796" alt="PR1" src="https://github.com/user-attachments/assets/a430a760-fb60-4fd4-ada9-6d37763c5075" />

<img width="1777" height="855" alt="PR1-1" src="https://github.com/user-attachments/assets/694bd19c-e960-4abf-b81f-019e52b7d17a" />



