# Incident Report - Simulated Compromise
**Date:** 2026-05-12
**Severity:** High
**Status:** Resolved

## Summary
Simulated attacker compromise detected and remediated on bv344server.

## Timeline
- 02:02 UTC - Supicious artifacts planted (simulation)
- 02:05 UTC - World-writable file detected in /tmp
- 02:05 UTC - Malicious cron job discovered in /etc/cron.d
- 02:05 UTC - Unauthorized user account found
- 02:08 UTC - All artifacts removed and user deleted
- 02:08 UTC - System verified clean

## Indicators of Compromise (IOCs)
1. /tmp/suspicious-script.sh - world-writable file (777)
2. /etc/cron.d/malicious - cron job downloading remote payload
3. suspicious-user - unauthorized user account (UID 1001)

## Response Actions
1. Removed malicious cron job
2. Deleted suspicious file
3. Locked then deleted backdoor user account
4. Verified system clean

## Root Cause
Simulated compromise for incident response training

## Lessons Learned
- Auth logs show all login attempts and sudo usage
- Cron jobs in /etc/cron.d/ are a common persistence mechanism
- World-writable files in /tmp are a red flag
- Always lock a user before deleting to prevent active sessions
