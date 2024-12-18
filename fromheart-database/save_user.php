<?php
$host = 'localhost'; // Replace with your database host
$dbname = 'fromheart_db'; // Replace with your database name
$username = 'root'; // Replace with your database username
$password = ''; // Replace with your database password

header("Content-Type: application/json");

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Check request method
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        echo json_encode(['success' => false, 'message' => 'Invalid request method']);
        exit;
    }

    // Retrieve input data
    $full_name = $_POST['full_name'] ?? '';
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    $address = $_POST['address'] ?? '';
    $birthday = $_POST['birthday'] ?? '';
    $gender = $_POST['gender'] ?? '';
    $nationality = $_POST['nationality'] ?? '';

    // Validate required fields
    if (
        empty($full_name) || empty($email) || empty($password) ||
        empty($address) || empty($birthday) || empty($gender) ||
        empty($nationality)
    ) {
        echo json_encode(['success' => false, 'message' => 'All fields are required']);
        exit;
    }

    // Log data (debugging purposes)
    error_log("Received Data: " . print_r($_POST, true));


    // Hash password before storing
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

    // Insert user data into database
    $stmt = $pdo->prepare("
        INSERT INTO users (full_name, email, password, address, birthday, gender, nationality)
        VALUES (:full_name, :email, :password, :address, :birthday, :gender, :nationality)
    ");

    $stmt->execute([
        ':full_name' => $full_name,
        ':email' => $email,
        ':password' => $hashedPassword,
        ':address' => $address,
        ':birthday' => $birthday,
        ':gender' => $gender,
        ':nationality' => $nationality,
    ]);

    // Check if the insertion was successful
    if ($stmt->rowCount() > 0) {
        echo json_encode(['success' => true, 'message' => 'Profile saved successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to save profile']);
    }
} catch (PDOException $e) {
    error_log("Database error: " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
} catch (Exception $e) {
    error_log("General error: " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
?>
