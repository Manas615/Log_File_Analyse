import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

import java.io.*;

public class LogAnalyzerTest {

    @Test
    public void testScriptWithValidLog() throws IOException, InterruptedException {
        // Prepare command
        ProcessBuilder pb = new ProcessBuilder("./log_analyzer.sh", "sample_log.log");
        pb.redirectErrorStream(true);
        Process process = pb.start();

        // Capture output
        BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
        StringBuilder output = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            output.append(line).append("\n");
        }
        int exitCode = process.waitFor();

        // Assertions
        assertEquals(0, exitCode, "Script should exit with code 0 for valid log");
        assertTrue(output.toString().contains("processed"), "Output should mention 'processed'");
    }

    @Test
    public void testScriptWithMissingLog() throws IOException, InterruptedException {
        ProcessBuilder pb = new ProcessBuilder("./log_analyzer.sh", "nonexistent.log");
        pb.redirectErrorStream(true);
        Process process = pb.start();

        BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
        StringBuilder output = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            output.append(line).append("\n");
        }
        int exitCode = process.waitFor();

        assertEquals(1, exitCode, "Script should exit with code 1 for missing file");
        assertTrue(output.toString().contains("File not found"), "Output should mention 'File not found'");
    }
}
