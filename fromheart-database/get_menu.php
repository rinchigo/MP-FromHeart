<?php
// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "fromheart";  // Replace with your database name

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Fetch all menu items from the database
$sql = "SELECT * FROM menu";
$result = $conn->query($sql);

$menuItems = [];

if ($result->num_rows > 0) {
    // Fetch each row and add to the $menuItems array
    while ($row = $result->fetch_assoc()) {
        $menuItems[] = [
            'id' => $row['id'],
            'menu_name' => $row['menu_name'],
            'image_url' => $row['image_url'],
            'price' => $row['price']  // Include the price in the response
        ];
    }
    echo json_encode($menuItems);
} else {
    echo json_encode(['error' => 'No menu items found']);
}

$conn->close();
?>
