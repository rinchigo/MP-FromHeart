<?php
// Enable error reporting for debugging (optional, remove in production)
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Database configuration
$servername = "localhost";
$username = "root"; // Replace with your database username
$password = "";     // Replace with your database password
$dbname = "fromheart_db"; // Your database name

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => 'Database connection failed: ' . $conn->connect_error]));
}

// Ensure the request method is POST
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Check if all required fields are set
    if (isset($_POST['item_name'], $_POST['item_description'], $_POST['item_price'], $_FILES['item_image'])) {
        // Get POST data
        $itemName = $_POST['item_name'];
        $itemDescription = $_POST['item_description'];
        $itemPrice = $_POST['item_price'];

        // Handle image upload
        $image = $_FILES['item_image'];
        $uploadDir = 'uploads/'; // Folder to save images

        // Create the uploads directory if it doesn't exist
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0755, true);
        }

        // Generate a unique filename to prevent overwriting
        $imagePath = $uploadDir . uniqid() . "_" . basename($image['name']);

        // Move the uploaded file to the target directory
        if (move_uploaded_file($image['tmp_name'], $imagePath)) {
            // Prepare SQL statement
            $stmt = $conn->prepare("INSERT INTO menu (name, description, price, image) VALUES (?, ?, ?, ?)");
            $stmt->bind_param("ssds", $itemName, $itemDescription, $itemPrice, $imagePath);

            if ($stmt->execute()) {
                echo json_encode(['success' => true, 'message' => 'Item added successfully']);
            } else {
                echo json_encode(['success' => false, 'message' => 'Failed to insert data into database']);
            }
            $stmt->close();
        } else {
            echo json_encode(['success' => false, 'message' => 'Failed to upload image']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Missing required fields']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid request method']);
}

// Close the database connection
$conn->close();
?>
