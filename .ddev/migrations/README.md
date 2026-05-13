# Database Migrations with WP Migrate Pro

This project uses **WP Migrate Pro** for database migrations between environments.

## Quick Start

### Pull from a remote environment

```bash
# Interactive menu
ddev migration

# Direct command
ddev run-migration develop              # Includes media via WP Migrate Pro
ddev run-migration master --skip-media  # Database only
```

### Via Makefile

```bash
make pull-staging      # Pull develop environment with automatic rsync fallback
make pull-production   # Pull master/production environment with automatic rsync fallback
```

These targets provide the best performance by attempting fast rsync for media first, then automatically falling back to WP Migrate Pro if SSH access is unavailable.

## Configuration

Migration connections are stored in **`.conf/migrations/connections.json`**.

See `.conf/migrations/README.md` for detailed configuration and security information.

## Commands

### `ddev migration`
Interactive menu for managing migrations:
- **Add connection**: Store WP Migrate Pro connection details
- **Pull from remote**: Import database (and optionally media) from remote environment
- **Push to remote**: Export local database to remote (non-production only)
- **List connections**: View all configured connections

### `ddev run-migration <branch> [--skip-media]`
Run a migration pull programmatically:
- Reads connection details from `connections.json`
- Syncs media via WP Migrate Pro by default
- Use `--skip-media` flag for database-only pulls
- Performs post-migration cleanup (deactivates cache plugins, restores wp-config.php)

### `ddev pull-media <branch>`
Sync media files via rsync (used by Makefile targets `make pull-staging` and `make pull-production`):
- Requires SSH access and proper credentials
- Much faster than WP Migrate Pro's built-in media transfer
- Makefile targets automatically fall back to WP Migrate Pro if rsync fails

## Adding Connections

### From WordPress Admin

1. Go to **WP Migrate DB Pro** settings on the remote site
2. Copy the connection string (format: `https://example.com secret-key`)
3. Run `ddev migration` and select "Add connection"
4. Paste the combined string when prompted
5. Enter a branch name (e.g., `develop`, `master`)
6. Optionally add a display label and description

### Example connections.json

```json
{
  "develop": {
    "url": "https://staging.example.com",
    "secret": "abc123...",
    "label": "Staging",
    "description": "Development staging environment"
  },
  "master": {
    "url": "https://www.example.com",
    "secret": "xyz789...",
    "label": "Production",
    "description": "Live production site"
  }
}
```

## Post-Migration Cleanup

After each pull, the system automatically:

1. **Deactivates cache plugins** that cause issues in local development:
   - WP Rocket
   - Redis Cache
   - W3 Total Cache

2. **Restores `wp-config.php`** from git to prevent committing production cache configuration

3. **Flushes WordPress cache** to ensure clean state

## Media Handling Strategies

Media handling differs depending on which command you use:

### Via `ddev migration` or `ddev run-migration`

These commands offer **two options**:

**Include media (default)**
- Syncs media using WP Migrate Pro's built-in transfer
- Works without SSH access
- Slower but reliable

**Skip media** (`--skip-media` flag)
- Database only, no media transfer
- Fastest option when you don't need updated media

### Via `make pull-staging` or `make pull-production`

These Makefile targets provide **automatic rsync with fallback**:

**Auto (rsync-first-with-fallback)**
- Attempts fast rsync for media sync first
- Automatically falls back to WP Migrate Pro if rsync is unavailable
- Best performance when SSH access is available
- Seamless degradation when SSH is blocked

## Security Notes

⚠️ **Connection secrets are stored in `.conf/migrations/connections.json`**

- Currently committed to the repository for team convenience
- Contains sensitive WP Migrate Pro secret keys
- Should be rotated regularly
- See `.conf/migrations/README.md` for security best practices

## Troubleshooting

### "Connection not found"
Run `ddev migration` → "Add connection" to configure the connection first.

### "Rsync failed"
This is normal if SSH access is blocked when using `make pull-staging` or `make pull-production`. The Makefile targets will automatically use WP Migrate Pro for media instead.

### "Plugin not found: wp-migrate-db-pro"
Make sure the plugin is installed and available. Run `ddev local-init` to activate required plugins.

### Media not syncing
- Try the interactive menu and select "Force WP Migrate Pro for media"
- Check that WP Migrate Pro's media addon is active on both local and remote
- Verify connection credentials are correct

## More Information

- [WP Migrate Pro Documentation](https://deliciousbrains.com/wp-migrate-db-pro/doc/)
- [WP Migrate Pro CLI Reference](https://deliciousbrains.com/wp-migrate-db-pro/doc/cli/)
- [Local Environment Documentation](../../../docs/local-environment.md)
