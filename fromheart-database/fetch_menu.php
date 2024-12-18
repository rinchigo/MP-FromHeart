<?php
header("Content-Type: application/json");

// Database configuration
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "fromheart_db";

// Connect to the database
$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => 'Database connection failed']));
}

// Fetch menu items
$sql = "SELECT name, price, image FROM menu";
$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $menuItems = [];
    while ($row = $result->fetch_assoc()) {
        $menuItems[] = $row;
    }
    echo json_encode(['success' => true, 'data' => $menuItems]);
} else {
    echo json_encode(['success' => false, 'message' => 'No menu items found']);
}

$conn->close();
?>
