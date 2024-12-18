<?php
header("Content-Type: application/json");

$host = "localhost";
$user = "root";
$password = "";
$database = "fromheart_db";

$conn = new mysqli($host, $user, $password, $database);

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Database connection failed"]));
}

$name = $_POST['name'];
$email = $_POST['email'];
$gender = $_POST['gender'];
$address = $_POST['address'];
$birthday = $_POST['birthday'];
$nationality = $_POST['nationality'];

if (!$name || !$email || !$gender || !$address || !$birthday || !$nationality) {
    echo json_encode(["success" => false, "message" => "All fields are required"]);
    exit();
}

$sql = "INSERT INTO user_details (name, email, gender, address, birthday, nationality) VALUES (?, ?, ?, ?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ssssss", $name, $email, $gender, $address, $birthday, $nationality);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Details saved successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to save details"]);
}

$stmt->close();
$conn->close();
?>
