<?php
if (isset($_GET['first']) && isset($_GET['second'])) {
 
    $num1 = $_GET['first'];
    $num2 = $_GET['second'];
    $result = $num1 * $num2;
    
    echo $result . "<br />";
    echo 'Hostname: \'' . gethostname() . '\'';
}
?>
