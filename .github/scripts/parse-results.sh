if [[ -f apexTestResults/test/test-result.txt ]]; then #1
    echo "Results found"
    # get list of failed tests | trim for class.test name only
    grep -w "Fail" apexTestResults/test/test-result.txt >> apexTestResults/test/step1.txt
    echo "Failures"
    echo "$(<apexTestResults/test/step1.txt)"
    grep -w "fHCM2" apexTestResults/test/step1.txt >> apexTestResults/test/step2.txt
    echo "Failing classes"
    echo "$(<apexTestResults/test/step2.txt)"
    failed=$(awk {'print $1'} apexTestResults/test/step2.txt)            
    echo "Parsed test results"
    echo "Failed tests = $failed"
    echo "$failed"
    if [[ -z "$failed" ]]; then #2
        echo "Tests passed"
        exit 0
    else #2
        echo "One or more tests failed"
        exit 1
    fi #2
else #1
    echo "File apexTestResults/test/test-result.txt not found - tests did not run"
    exit 1		
fi #1
