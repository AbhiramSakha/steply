package org.jsmart.steply.cli;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.jsmart.steply.core.SteplyCommandRunner;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.Properties;

public class SteplyCLI {

    public static void main(String[] args) {
        System.exit(run(args));
    }

    /**
     * Executes CLI logic and returns an exit code.
     * This method exists so tests can invoke CLI logic
     * without triggering System.exit().
     */
    public static int run(String[] args) {

        Options options = buildCliOptions();
        CommandLineParser parser = new DefaultParser();

        try {

            CommandLine cmd = parser.parse(options, args);

            if (cmd.hasOption("h")) {
                new HelpFormatter().printHelp("steply", options);
                return 0;
            }

            if (cmd.hasOption("v")) {
                System.out.println("Steply Test Execution Version " + readVersion());
                return 0;
            }

            //// Uncomment this and run the "main()" above using the IDE play-button. It executes the real test(happy case) ////
            // String scenario = "/Users/nchandra/Downloads/STEPLY_WORKSPACE/steply/steply-core/src/main/resources/helloworld/hello_world_status_ok_assertions_new.json";
            // String targetEnv = "/Users/nchandra/Downloads/STEPLY_WORKSPACE/steply/steply-core/src/main/resources/config/github_host_new.properties";
            // String suiteFolder = null;

            String scenario = cmd.getOptionValue("s");
            String suiteFolder = cmd.hasOption("suite") ? cmd.getOptionValue("suite") : cmd.getOptionValue("f");
            String targetEnv = cmd.getOptionValue("t");
            String hostConfig = cmd.getOptionValue("hc");

            String reports = cmd.getOptionValue("r", "target");
            String logLevel = cmd.getOptionValue("l", "INFO");

            if ((scenario == null && suiteFolder == null) || (scenario != null && suiteFolder != null)) {
                System.err.println("Either --scenario (-s) OR --folder (-f) or --suite must be provided (mutually exclusive).");
                new HelpFormatter().printHelp("steply", options);
                return 1;
            }

            // Making --target-env  or --host as optional. Only show warning, but run it.
            if (targetEnv == null && hostConfig == null) {
                System.err.println("Steply: No --target-env (-t) OR --host (-hc) was provided. If it is intentional, you can safely ignore this warning, \notherwise, please provide target environment details. Running in default mode.");
                try (InputStream in = SteplyCLI.class.getClassLoader().getResourceAsStream("config/default.properties")) {
                    if (in != null) {
                        File tmp = File.createTempFile("steply-default", ".properties");
                        tmp.deleteOnExit();
                        Files.copy(in, tmp.toPath(), StandardCopyOption.REPLACE_EXISTING);
                        targetEnv = tmp.getAbsolutePath();
                    }
                }
            }

            if (targetEnv != null && hostConfig != null) {
                System.err.println("Only one of --target-env (-t) OR --host (-hc) should be provided (mutually exclusive).");
                new HelpFormatter().printHelp("steply", options);
                return 1;
            }

            // Normalize hostConfig -> targetEnv
            if (hostConfig != null) {
                targetEnv = hostConfig;
            }

            if (suiteFolder != null) {
                SteplyCommandRunner runner =
                        new SteplyCommandRunner(null, suiteFolder, targetEnv, reports, logLevel);
                runner.runSuite();
            }

            if (scenario != null) {
                SteplyCommandRunner runner =
                        new SteplyCommandRunner(scenario, null, targetEnv, reports, logLevel);
                runner.runSingleScenario();
            }

            return 0;

        } catch (ParseException pe) {

            System.err.println("Error parsing arguments: " + pe.getMessage());
            new HelpFormatter().printHelp("steply", options);
            return 1;

        } catch (Exception e) {

            System.err.println("Execution failed: " + e.getMessage());
            e.printStackTrace(System.err);
            return 2;
        }
    }

    private static Options buildCliOptions() {

        Options options = new Options();

        options.addOption(Option.builder("s").longOpt("scenario").hasArg()
                .desc("Single scenario file path").build());

        options.addOption(Option.builder("f").longOpt("folder").hasArg()
                .desc("Folder(Test Suite) containing multiple scenarios").build());

        options.addOption(Option.builder().longOpt("suite").hasArg()
                .desc("Test Suite containing multiple scenarios : Alias for --folder").build());

        options.addOption(Option.builder("t").longOpt("target-env").hasArg()
                .desc("Target environment properties file").build());

        options.addOption(Option.builder("hc").longOpt("host").hasArg()
                .desc("Host(s) configuration properties file path").build());

        options.addOption(Option.builder("r").longOpt("reports").hasArg()
                .desc("Custom report output directory (default is ./target)").build());

        options.addOption(Option.builder("l").longOpt("log-level").hasArg()
                .desc("Logging level (WARN/INFO/DEBUG)").build());

        options.addOption("v", "version", false, "Show version information");
        options.addOption("h", "help", false, "Show help");

        return options;
    }

    private static String readVersion() {

        String home = System.getProperty("steply.home", ".");
        File versionFile = new File(home, "VERSION.txt");

        if (versionFile.exists()) {
            try (FileInputStream fis = new FileInputStream(versionFile)) {

                Properties props = new Properties();
                props.load(fis);

                String version = props.getProperty("steply.version");
                if (version != null) {
                    return version;
                }

            } catch (IOException ignored) {
                System.out.println("Could not read version info. You can safely ignore this.");
            }
        }

        return "unknown";
    }
}