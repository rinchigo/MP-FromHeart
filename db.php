<?php
$servername = "localhost";  // Host (usually 'localhost' for local servers)
$username = "root";  // Your MySQL username (usually 'root' for local)
$password = " ";  // Your MySQL password (if any)
$dbname = "fromheart";  // The name of your database

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}
?>
