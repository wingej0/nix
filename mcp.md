# MCP Server Setup Status

## Completed Setup

### Persistence Configuration
- `~/.claude/` directory - persisted via `modules/ai.nix`
- `~/.claude.json` file - persisted via `modules/ai.nix`
- Removed `/etc/cups` from `modules/persist.nix` (NixOS symlink incompatible with impermanence)

### MCP Servers Configured
Both servers added at user scope (`-s user`):

1. **n8n-mcp**
   - Command: `npx -y n8n-mcp`
   - Environment variables:
     - `N8N_API_URL=https://localhost`
     - `N8N_API_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxYWM3ZWM1OC1lNWYxLTRjMWMtOGNiMy03ODcwZjc4ZjM4OGQiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzY4MDY3MzA2LCJleHAiOjE3NzA2MjA0MDB9.X4SmFQVVQ-38mqgPQjJUN_UriyEJzJajmtR6TaxHCCg`
     - `MCP_MODE=stdio`

2. **anytype**
   - Command: `npx -y @anyproto/anytype-mcp`
   - Environment variables:
     - `OPENAPI_MCP_HEADERS={"Authorization":"Bearer RNDPzPLc9Bm1VZoL+7vdcGK/3RW8g1HNM/Qqi6z/KmQ=", "Anytype-Version":"2025-11-08"}`
   - **Requirement**: Anytype desktop app must be running for this MCP to connect

### Skills Plugin
- **n8n-mcp-skills** v1.1.0 - installed at user scope
- Install path: `~/.claude/plugins/cache/n8n-mcp-skills/n8n-mcp-skills/1.1.0`

### Printer Configuration
Added declarative printer config to `hosts/darter-pro/configuration.nix`:
- Canon GPR-53 at 10.40.0.70 (LPD, default printer)
- HP printers auto-discover via cups-browsed

## After Reboot Verification

Run these commands to verify everything is working:

```bash
# Check MCP servers
claude mcp list

# Check if persistence is working
ls -la ~/.claude.json  # Should be symlink to /persist/...
ls -la ~/.claude/      # Should be symlink to /persist/...

# Check printers
lpstat -p
```

## GitHub References
- n8n-mcp: https://github.com/czlonkowski/n8n-mcp
- n8n-skills: https://github.com/czlonkowski/n8n-skills
- anytype-mcp: https://github.com/anyproto/anytype-mcp

## Files Modified
- `modules/persist.nix` - removed `/etc/cups`
- `modules/ai.nix` - already had Claude persistence (no changes needed)
- `hosts/darter-pro/configuration.nix` - added declarative printer config
