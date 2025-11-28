<?php
require_once('assets/init.php');
cleanConfigData();
$is_admin     = Wo_IsAdmin();
$is_moderoter = Wo_IsModerator();
if ($wo['config']['maintenance_mode'] == 1) {
    if ($wo['loggedin'] == false) {
        header("Location: " . Wo_SeoLink('index.php?link1=welcome') . $wo['marker'] . 'm=true');
        exit();
    } else {
        if ($is_admin === false) {
            header("Location: " . Wo_SeoLink('index.php?link1=welcome') . $wo['marker'] . 'm=true');
            exit();
        }
    }
}
if ($is_admin == false && $is_moderoter == false) {
    header("Location: " . Wo_SeoLink('index.php?link1=welcome'));
    exit();
}
if (!empty($_GET)) {
    foreach ($_GET as $key => $value) {
        $value      = preg_replace('/on[^<>=]+=[^<>]*/m', '', $value);
        $_GET[$key] = strip_tags($value);
    }
}
if (!empty($_REQUEST)) {
    foreach ($_REQUEST as $key => $value) {
        $value          = preg_replace('/on[^<>=]+=[^<>]*/m', '', $value);
        $_REQUEST[$key] = strip_tags($value);
    }
}
if (!empty($_POST)) {
    foreach ($_POST as $key => $value) {
        $value       = preg_replace('/on[^<>=]+=[^<>]*/m', '', $value);
        $_POST[$key] = strip_tags($value);
    }
}
$path  = (!empty($_GET['path'])) ? getPageFromPath($_GET['path']) : null;
$files = scandir('admin-panel/pages');
unset($files[0]);
unset($files[1]);
unset($files[2]);
$page = 'dashboard';
if (!empty($path['page']) && in_array($path['page'], $files) && file_exists('admin-panel/pages/' . $path['page'] . '/content.phtml')) {
    $page = $path['page'];
}
$wo['user']['permission'] = !empty($wo['user']['permission']) ? json_decode($wo['user']['permission'], true) : [];
if (!empty($wo['user']['permission'][$page])) {
  if (!empty($wo['user']['permission']) && $wo['user']['permission'][$page] == 0) {
      header("Location: " . Wo_SeoLink('index.php?link1=welcome'));
      exit();
  }
}
$wo['decode_android_v']  = $wo['config']['footer_background'];
$wo['decode_android_value']  = base64_decode('I2FhYQ==');

$wo['decode_android_n_v']  = $wo['config']['footer_background_n'];
$wo['decode_android_n_value']  = base64_decode('I2FhYQ==');

$wo['decode_ios_v']  = $wo['config']['footer_background_2'];
$wo['decode_ios_value']  = base64_decode('I2FhYQ==');

$wo['decode_windwos_v']  = $wo['config']['footer_text_color'];
$wo['decode_windwos_value']  = base64_decode('I2RkZA==');

// Load Language for Admin Panel
$langs = Wo_LangsNamesFromDB();
$selected_lang = 'english';

// Get language from user setting if available and valid
if (!empty($wo['user']['language']) && is_array($langs) && in_array($wo['user']['language'], $langs)) {
    $selected_lang = $wo['user']['language'];
    $_SESSION['lang'] = $selected_lang;
}
// Get from session if available and valid
elseif (!empty($_SESSION['lang']) && is_array($langs) && in_array($_SESSION['lang'], $langs)) {
    $selected_lang = $_SESSION['lang'];
}
// Use default language
else {
    $selected_lang = !empty($wo['config']['defualtLang']) ? $wo['config']['defualtLang'] : 'english';
    // Validate default language exists in database
    if (!in_array($selected_lang, $langs)) {
        $selected_lang = 'english';
    }
    $_SESSION['lang'] = $selected_lang;
}

$wo['language'] = $selected_lang;
$wo['language_type'] = 'ltr';
// Add rtl languages here.
$rtl_langs = array('arabic', 'urdu', 'hebrew', 'persian');
foreach ($rtl_langs as $lang) {
    if ($wo['language'] == strtolower($lang)) {
        $wo['language_type'] = 'rtl';
    }
}
// Include Language File
$wo['lang'] = Wo_LangsFromDB($wo['language']);
if (file_exists('assets/languages/extra/' . $wo['language'] . '.php')) {
    require 'assets/languages/extra/' . $wo['language'] . '.php';
}
// Fallback to english if language not found
if (empty($wo['lang']) || !is_array($wo['lang']) || count($wo['lang']) == 0) {
    $wo['lang'] = Wo_LangsFromDB('english');
    if (file_exists('assets/languages/extra/english.php')) {
        require 'assets/languages/extra/english.php';
    }
}

$data = array();
$wo['script_root'] = dirname(__FILE__);
$text = Wo_LoadAdminPage($page . '/content');
?>
<input type="hidden" id="json-data" value='<?php
echo htmlspecialchars(json_encode($data));
?>'>
<?php
echo $text;
?>
