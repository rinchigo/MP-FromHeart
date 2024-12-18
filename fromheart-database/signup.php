<?php
header("Content-Type: application/json");

$host = "localhost";
$user = "root"; // Your database username
$password = ""; // Your database password
$database = "fromheart_db";

$conn = new mysqli($host, $user, $password, $database);

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Database connection failed"]));
}

$name = $_POST['name'];
$email = $_POST['email'];
$password = password_hash($_POST['password'], PASSWORD_BCRYPT);

if (!$name || !$email || !$password) {
    echo json_encode(["success" => false, "message" => "All fields are required"]);
    exit();
}

$sql = "INSERT INTO users (name, email, password) VALUES (?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sss", $name, $email, $password);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Registration successful"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to register"]);
}

$stmt->close();
$conn->close();
?>
