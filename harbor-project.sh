#!/bin/bash

curl -k -i -u admin:Pass1234! 'POST' 'https://harbor.datamarket.local:9443/api/v2.0/projects' -H 'accept: application/json' -H 'X-Resource-Name-In-Location: false' -H 'Content-Type: application/json' -d '{
  "project_name": "string",
  "cve_allowlist": {
    "items": [
    ],
    "project_id": 4,
    "id": 4
  },
  "metadata": {
    "enable_content_trust": "false",
    "enable_content_trust_cosign": "false",
    "auto_scan": "false",
    "severity": "low",
    "prevent_vul": "false",
    "public": "true",
    "reuse_sys_cve_allowlist": "true"
  }
}'
