# MOSAIC GOVERNANCE STATE — MVP v1.0
**Document Metadata:**
- Created: 2025-12-06
- Last Updated: 2025-12-06 by Gemini
- Status: ACTIVE

Active Mode: OPTION A  
Active Benchmark Addendum: v1.1.2

## ACTIVE STATE RULES

### 2.4 Repo Synchronization & Drift Governance

A. Scheduled Sync  
- Sync script path: /Users/damianseguin/.local/bin/google-drive-sync.sh  
- Trigger: LaunchAgents at 12:00, 18:00, 21:00 daily.  
- Function:  
  1. Push LOCAL → GDrive Master  
  2. Push LOCAL → GDrive Consulting Mirror  

B. Manual Sync Protocol (Session Mode)  
When updating governance files or any architectural documentation, human operator runs:  
    /Users/damianseguin/.local/bin/google-drive-sync.sh  
This ensures all LLMs receive the updated state immediately.

C. Drift Detection Rule  
If Mirror differs from Master, Mirror is always assumed stale.  
Mirror must be overwritten from LOCAL during the next sync cycle.

D. AI Access Rule  
- ChatGPT Web: Reads from Consulting Mirror only.  
- Gemini Terminal: Reads/writes LOCAL only.  
- Claude Terminal: Reads/writes LOCAL only.  
- Codex (Cursor): Reads/writes LOCAL only.

Agents MUST NOT directly write to GDrive. Only the sync service performs cloud writes.