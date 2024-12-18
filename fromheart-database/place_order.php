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

// Get POST data
$data = json_decode(file_get_contents("php://input"), true);

$items = $data['items'];
$subtotal = $data['subtotal'];
$discount = $data['discount'];
$finalTotal = $data['final_total'];
$promoCode = $data['promo_code'];

// Insert into database
$sql = "INSERT INTO orders (items, subtotal, discount, final_total, promo_code) 
        VALUES ('" . json_encode($items) . "', $subtotal, $discount, $finalTotal, '$promoCode')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(['success' => true, 'message' => 'Order placed successfully']);
} else {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $conn->error]);
}

$conn->close();
?>
