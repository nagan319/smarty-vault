---
tags: [dashboard]
---
# 🧠 SMARTY VAULT: ACADEMIC NETWORK DASHBOARD

This dashboard links to all your people, organizations, and events, allowing you to quickly review your professional academic contacts.

## People
```dataview
list from "04.vault/00.academic-network/01.people"
sort file.name asc
```

## Organizations
```dataview
list from "04.vault/00.academic-network/02.orgs"
sort file.name asc
```

## Events
```dataview
list from "04.vault/00.academic-network/03.events"
sort file.name desc
```
