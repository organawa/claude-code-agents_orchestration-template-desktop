# Troubleshooting Guide

> Last updated: {{DATE}}

## Debug Protocol

1. **Enable debug mode**: `/enable-debug`
2. **Reproduce** the exact issue
3. **Check logs** before investigating code
4. **Identify** the specific file, function, and line
5. **Root cause** — trace from symptom to cause
6. **Fix** — minimal change only
7. **Verify** — run tests to confirm

## Common Issues

<!-- Add issues as they are discovered -->
<!-- Example:
### API returns 401 on valid token
**Symptom:** Authenticated requests fail with 401
**Cause:** JWT expired or clock skew between services
**Fix:** Check token expiry, verify server time
-->

### Dev servers not starting
**Symptom:** `lsof -i :{{DEV_PORT_BACKEND}}` shows nothing
**Cause:** Port already in use or missing dependencies
**Fix:** Kill existing process on port, reinstall dependencies

### Tests fail in CI but pass locally
**Symptom:** Tests pass on local machine but fail in CI
**Cause:** Usually environment differences (missing env vars, different OS)
**Fix:** Check CI environment configuration

## Known Quirks

<!-- Document quirky behavior that isn't a bug but could confuse debugging -->

## Environment-Specific Issues

<!-- Issues that only happen in dev or prod -->
