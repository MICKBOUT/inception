<?php
$defaultServer = getenv("ADMINER_DEFAULT_SERVER");
if ($defaultServer && !isset($_GET["server"])) {
    $_GET["server"] = $defaultServer;
}
require __DIR__ . "/adminer.php";
