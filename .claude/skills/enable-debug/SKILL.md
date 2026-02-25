---
name: enable-debug
description: Enable debug mode for troubleshooting issues
---

# Enable Debug Mode

Enable debug logging to troubleshoot issues. Always check logs before investigating code.

**Usage:** `/enable-debug`

**Workflow:**

## 1. Backend Debug Mode

### Temporary (current session):
Set the `LOG_LEVEL` environment variable to `DEBUG` and restart your backend server:
```bash
LOG_LEVEL=DEBUG {{DEV_SERVER_BACKEND}}
```

### Persistent (set in environment):
Add to your `.env` file:
```
LOG_LEVEL=DEBUG
```

Then restart the backend server.

### View Backend Logs
Logs will show in the terminal where the backend server is running.

## 2. Frontend Debug Mode

### Enable in Browser Console:
```javascript
localStorage.setItem('debug', 'true')
```

Then refresh the page (Cmd+R / Ctrl+R).

### View Frontend Logs
Open browser DevTools (F12) and check Console tab.

### Disable Debug Mode:
```javascript
localStorage.removeItem('debug')
```

## 3. Reproduce the Issue

**CRITICAL:** After enabling debug mode:
1. **Reproduce the exact issue** that needs investigation
2. **Check logs FIRST** before looking at code
3. **Look for:**
   - Error messages
   - Stack traces
   - Timing information
   - API request/response data
   - State changes

## 4. Common Debug Patterns

### API Call Issues:
Look for:
- Request URL and parameters
- Response status codes
- Response body
- CORS errors
- Authentication failures

### State Management Issues:
Look for:
- State update logs
- Component re-render triggers
- Store mutations

### Performance Issues:
Look for:
- Slow API calls (response times)
- Large data payloads
- Multiple re-renders

## 5. Analyzing Logs

**Workflow:**
1. Enable debug -> Reproduce -> Check logs -> Analyze -> Investigate code
2. **NOT:** Investigate code -> Guess -> Try fixes

---

**Remember:** Logs first, code investigation second. Debug mode saves hours of guessing.
