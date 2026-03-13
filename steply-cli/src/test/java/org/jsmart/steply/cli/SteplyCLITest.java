package org.jsmart.steply.cli;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

/**
 * Unit tests for SteplyCLI argument parsing and invocation paths.
 * <p>
 * Since SteplyCLI now exposes run(String[] args) returning an exit code,
 * tests can call it directly without intercepting System.exit().
 */
public class SteplyCLITest {

    private final PrintStream originalOut = System.out;
    private final PrintStream originalErr = System.err;

    private ByteArrayOutputStream outContent;
    private ByteArrayOutputStream errContent;

    @Before
    public void setUp() {
        outContent = new ByteArrayOutputStream();
        errContent = new ByteArrayOutputStream();

        System.setOut(new PrintStream(outContent));
        System.setErr(new PrintStream(errContent));
    }

    @After
    public void tearDown() {
        System.setOut(originalOut);
        System.setErr(originalErr);
    }

    @Test
    public void helpOption_shouldPrintUsageAndExit0() {

        int status = SteplyCLI.run(new String[]{"-h"});

        assertEquals(0, status);

        String out = outContent.toString();
        assertTrue("Help output should contain usage information",
                out.toLowerCase().contains("usage"));
    }

    @Test
    public void versionOption_shouldPrintVersionAndExit0() {

        int status = SteplyCLI.run(new String[]{"-v"});

        assertEquals(0, status);

        String out = outContent.toString();
        assertTrue("Version output should mention Steply Test Execution",
                out.contains("Steply Test Execution Version"));
    }

    @Test
    public void missingTargetAndHost_shouldPrintWarning_butProceedExecution() {

        int status = SteplyCLI.run(new String[]{"-s", "some-scenario.json"});

        // exit code 2 confirms execution proceeded past the env-check (not failed-fast with 1)
        assertEquals(2, status);

        String err = errContent.toString();
        assertTrue(err.contains("Running in default mode."));
    }

    @Test
    public void bothTargetAndHostProvided_shouldPrintErrorAndExit1() {

        int status = SteplyCLI.run(new String[]{
                "-s", "sc.json",
                "-t", "t.properties",
                "-hc", "host.properties"
        });

        assertEquals(1, status);

        String err = errContent.toString();
        assertTrue(err.contains("Only one of --target-env (-t) OR --host (-hc) should be provided"));
    }
}
