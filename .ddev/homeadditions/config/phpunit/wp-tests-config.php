<?php

/* Path to the WordPress codebase you'd like to test. Add a forward slash in the end. */
define( 'ABSPATH', dirname( __FILE__ ) . '/wp/' );

define( 'WP_CONTENT_DIR', dirname( __FILE__ ) . '/wp-content' );

// Test with multisite enabled.
// Alternatively, use the tests/phpunit/multisite.xml configuration file.
// define( 'WP_TESTS_MULTISITE', true );

// Force known bugs to be run.
// Tests with an associated Trac ticket that is still open are normally skipped.
// define( 'WP_TESTS_FORCE_KNOWN_BUGS', true );

// Test with WordPress debug mode (default).
define( 'WP_DEBUG', true );

// ** MySQL settings ** //

// This configuration file will be used by the copy of WordPress being tested.
// wordpress/wp-config.php will be ignored.

// WARNING WARNING WARNING!
// These tests will DROP ALL TABLES in the database with the prefix named below.
// DO NOT use a production database or one that is shared with something else.

define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

$table_prefix  = 'wptests_';   // Only numbers, letters, and underscores please!

define( 'WP_TESTS_DOMAIN', 'example.org' );
define( 'WP_TESTS_EMAIL', 'admin@example.org' );
define( 'WP_TESTS_TITLE', 'Test Blog' );

define( 'WP_PHP_BINARY', 'php' );

define( 'WPLANG', '' );

// ==============================
// Composer autoloader if present
// ==============================
if (file_exists(__DIR__ . '/wp-content/vendor/autoload.php')) {
    define('USE_COMPOSER_AUTOLOADER', true);
    require_once __DIR__ . '/wp-content/vendor/autoload.php';
}

// ===================================================
// Load database info and local development parameters
// ===================================================
if (file_exists(__DIR__ . '/local-tests-config.php')) {
    include(__DIR__ . '/local-tests-config.php');
}

// ===================================================
// Initialize Situation defaults
// ===================================================
if (class_exists('\Situation\WPConfig')) {
    new \Situation\WPConfig(__DIR__);
}
