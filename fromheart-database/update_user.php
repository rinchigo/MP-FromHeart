<?php
$host = 'localhost'; // Replace with your database host
$dbname = 'fromheart_db'; // Replace with your database name
$username = 'root'; // Replace with your database username
$password = ''; // Replace with your database password

header("Content-Type: application/json"); // Ensure responses are JSON

try {
    // Establish database connection
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Check if the request method is POST
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $email = $_POST['email'] ?? '';
        $full_name = $_POST['full_name'] ?? '';
        $address = $_POST['address'] ?? '';
        $birthday = $_POST['birthday'] ?? '';
        $gender = $_POST['gender'] ?? '';
        $nationality = $_POST['nationality'] ?? '';
        $job = $_POST['job'] ?? '';

        // Validate input
        if (empty($email) || empty($full_name) || empty($address) || empty($birthday) || empty($gender) || empty($nationality) || empty($job)) {
            echo json_encode(['success' => false, 'message' => 'All fields are required']);
            exit;
        }

        // Handle profile picture upload
        $targetDir = "uploads/";
        if (!is_dir($targetDir)) {
            mkdir($targetDir, 0777, true);
        }

        $profilePicturePath = null;
        if (!empty($_FILES['profile_picture']['name'])) {
            $fileName = time() . "_" . basename($_FILES["profile_picture"]["name"]);
            $targetFilePath = $targetDir . $fileName;

            if (move_uploaded_file($_FILES["profile_picture"]["tmp_name"], $targetFilePath)) {
                $profilePicturePath = $targetFilePath;
            } else {
                echo json_encode(['success' => false, 'message' => 'Failed to upload profile picture']);
                exit;
            }
        }

        // Update user data in database
        $stmt = $pdo->prepare(
            "UPDATE users 
            SET full_name = :full_name, address = :address, birthday = :birthday, 
                gender = :gender, nationality = :nationality, job = :job, 
                profile_picture = COALESCE(:profile_picture, profile_picture) 
            WHERE email = :email"
        );

        $stmt->execute([
            ':full_name' => $full_name,
            ':address' => $address,
            ':birthday' => $birthday,
            ':gender' => $gender,
            ':nationality' => $nationality,
            ':job' => $job,
            ':profile_picture' => $profilePicturePath,
            ':email' => $email
        ]);

        if ($stmt->rowCount() > 0) {
            echo json_encode(['success' => true, 'message' => 'Profile updated successfully']);
        } else {
            echo json_encode(['success' => false, 'message' => 'No changes made or user not found']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid request method']);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}
?>
