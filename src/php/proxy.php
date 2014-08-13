<?php
// Create a stream
//$cred = sprintf('Authorization: Basic %s',
//    base64_encode('edu:cI-ovTlnDY1LynywJl45') );
$opts = array(
    'http'=>array(
    'method'=>'GET')
 //   'header'=>$cred)
);

$context = stream_context_create($opts);

echo file_get_contents($_GET['link'], false, $context);
?>
