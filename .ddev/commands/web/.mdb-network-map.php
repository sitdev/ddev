<?php
/**
 * WP-CLI: `wp mdb-network-map <url> <secret>` — print the remote WP Migrate
 * connection-verify payload (tables, prefixed_tables, prefix, subsites,
 * site_details.subsites_info, is_subdomain_install, ...) as JSON on stdout.
 *
 * Loaded on demand from the migration tooling:
 *   wp --require=.ddev/commands/web/.mdb-network-map.php mdb-network-map <url> <secret>
 *
 * Reuses the plugin's own Connection\Local verify path so plugin-version
 * mismatch, remote license and allow_pull failures surface as the plugin's
 * own error messages (non-zero exit via WP_CLI::error()).
 */

if (!defined('WP_CLI') || !WP_CLI) {
    return;
}

WP_CLI::add_command('mdb-network-map', function ($args) {
    if (count($args) < 2) {
        WP_CLI::error('Usage: wp mdb-network-map <url> <secret>');
    }
    list($url, $secret) = $args;

    if (!class_exists('\DeliciousBrains\WPMDB\WPMDBDI')) {
        WP_CLI::error('wp-migrate-db-pro is not loaded — activate it, or use the wire-protocol client.');
    }

    $di = \DeliciousBrains\WPMDB\WPMDBDI::getInstance();

    // The verify path branches on CLI mode for POST handling (Helper::
    // convert_json_body_to_post), error output and response encoding
    // (Http::end_ajax). DynamicProperties is a Singleton, but set it via the
    // container too in case the DI wiring holds a distinct instance.
    \DeliciousBrains\WPMDB\Common\Properties\DynamicProperties::getInstance()->doing_cli_migration = true;
    $di->get(\DeliciousBrains\WPMDB\Common\Properties\DynamicProperties::class)->doing_cli_migration = true;

    // Mirrors Pro\Cli\Extra\Cli::verify_connection_to_remote_site(): the
    // verify handler reads its state from $_POST.
    $_POST = [
        'action' => 'wpmdb_verify_connection_to_remote_site',
        'intent' => 'pull',
        'url'    => $url,
        'key'    => $secret,
    ];

    $local    = $di->get(\DeliciousBrains\WPMDB\Pro\Migration\Connection\Local::class);
    $response = $local->ajax_verify_connection_to_remote_site();

    if (is_wp_error($response)) {
        WP_CLI::error($response->get_error_message());
    }
    if (!is_string($response)) {
        $response = json_encode($response);
    }
    if (empty($response)) {
        WP_CLI::error('Empty response from the WP Migrate verify handshake.');
    }

    $decoded = json_decode($response, true);
    if (!is_array($decoded) || !array_key_exists('tables', $decoded)) {
        WP_CLI::error('The WP Migrate verify handshake did not return a site map.');
    }

    WP_CLI::line($response);
});
