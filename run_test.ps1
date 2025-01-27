# Set variables
$DeviceSize = "1080x1920"
$ON_DEVICE_OUTPUT_FILE = "/sdcard/E2E_TC_001.mp4"
$OUTPUT_VIDEO = "E2E_TC_001.mp4"
$DRIVER_PATH = "test_driver/integration_test_driver.dart"
$TEST_PATH = "integration_test/E2E_TC_001.dart"
$DeviceId = "27c2f180b9217ece"

# Remove existing video if it exists
if (Test-Path $OUTPUT_VIDEO) { Remove-Item $OUTPUT_VIDEO }

# Start screen recording in the background
$screenrecordProcess = Start-Process -FilePath adb -ArgumentList "-s $DeviceId shell screenrecord --size $DeviceSize --time-limit 180 $ON_DEVICE_OUTPUT_FILE" -PassThru -NoNewWindow

# Wait a bit longer to ensure the process starts
Start-Sleep -Seconds 4

# Check if screenrecord started successfully
if (-not $screenrecordProcess) {
    Write-Error "Failed to start screen recording."
    exit 1
}

# Run the Flutter drive test. Capture exit code.
flutter drive --device-id="$DeviceId" --driver="$DRIVER_PATH" --target="$TEST_PATH"
$TestResult = $LASTEXITCODE

# Stop the screen recording (improved handling)
if ($screenrecordProcess -and -not $screenrecordProcess.HasExited) {
    try {
        Stop-Process -Id $screenrecordProcess.Id -Force # Force stop if needed
    }
    catch {
        Write-Warning "Could not stop screen recording process. Trying to kill it."
        adb -s $DeviceId shell "pkill -f screenrecord"
    }
}
elseif ($screenrecordProcess -and $screenrecordProcess.HasExited) {
    Write-Warning "Screen recording process exited on its own."
}
else {
    Write-Warning "Screen recording process not found."
}

# Pull the video file from the device (only if the test passed)
if ($TestResult -eq 0) {
    adb -s $DeviceId pull "$ON_DEVICE_OUTPUT_FILE" "$OUTPUT_VIDEO"
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed to pull video file. ADB Exit Code: $($LASTEXITCODE)"
    }
}
else {
    Write-Warning "Test failed. Skipping video pull."
}

# Clean up the on-device video (even if pull failed)
adb -s $DeviceId shell "rm $ON_DEVICE_OUTPUT_FILE"

exit $TestResult