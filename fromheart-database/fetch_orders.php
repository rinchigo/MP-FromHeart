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

// Fetch orders
$sql = "SELECT id as order_id, items, final_total, order_date, 'Take Away' as order_type, 
               'Order Completed' as status, 'Combo Kopi dan Toast 20k' as description 
        FROM orders";
$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $orderList = [];
    while ($row = $result->fetch_assoc()) {
        $orderList[] = $row;
    }
    echo json_encode(['success' => true, 'data' => $orderList]);
} else {
    echo json_encode(['success' => false, 'message' => 'No orders found']);
}

$conn->close();
?>
