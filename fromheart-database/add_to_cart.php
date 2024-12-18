<?php
header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "fromheart_db";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Connection failed: " . $conn->connect_error]));
}

// Read JSON input
$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['product_id']) && isset($data['quantity'])) {
    $productId = $data['product_id'];
    $quantity = $data['quantity'];

    // Insert or update cart
    $sql = "INSERT INTO cart_items (product_id, quantity) 
            VALUES ('$productId', '$quantity') 
            ON DUPLICATE KEY UPDATE quantity = quantity + $quantity";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["success" => true, "message" => "Product added to cart successfully"]);
    } else {
        echo json_encode(["success" => false, "message" => "Database error: " . $conn->error]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid input data"]);
}

$conn->close();
?>
