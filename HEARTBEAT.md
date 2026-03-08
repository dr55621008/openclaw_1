# HEARTBEAT.md - Regular Checks

## Email & Calendar Check

**Frequency:** 2-3 times per day (morning, afternoon, evening)

### What to Check

1. **Gmail** - Unread emails in last 24 hours
   ```bash
   gog gmail messages search "in:inbox newer_than:1d" --max 10
   ```

2. **Calendar** - Events in next 48 hours
   ```bash
   gog calendar events primary --from "$(date -Iseconds)" --to "$(date -d '+48 hours' -Iseconds)"
   ```

3. **Flight Price Monitor** - Already running (every 6 hours)
   - Check log: `cat /tmp/flight-monitor.log`
   - Process: `ps aux | grep monitor-runner`

### When to Alert

- **Urgent email** from important contacts
- **Calendar event** within 2 hours
- **Flight price drop** >10% for monitored routes

### Quiet Hours

- **23:00-08:00** - Only alert for urgent matters
- **Weekend** - Same unless travel-related

---

## Last Check Status

| Check | Last Run | Status |
|-------|----------|--------|
| Gmail | 2026-03-08 17:55 | ✅ 2 unread |
| Calendar | 2026-03-08 17:55 | ✅ No events |
| Flight Monitor | Running | ✅ PID 369 |
