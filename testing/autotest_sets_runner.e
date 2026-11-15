note
	description: "[
		Runs the tests in simple_encoding's AutoTest test sets that TEST_APP did not call
		(port-coordination #17: 1 of them ran in no gate). Each goes through AutoTest's own
		EQA_TEST_EVALUATOR: a fresh test set (on_prepare), the test, then clean (on_clean),
		as AutoTest runs it. A failing test prints "FAIL:" with its tag and is counted.
	]"

class
	AUTOTEST_SETS_RUNNER

feature -- Counts

	passed, failed: INTEGER
			-- Tests run here.

feature -- Running

	run_all
			-- Every test below, 1 in all.
		do
			run_lib_tests
		end

feature {NONE} -- Test sets

	run_lib_tests
		local
			l_evaluator: EQA_TEST_EVALUATOR [LIB_TESTS]
		do
			create l_evaluator
			report (l_evaluator.execute (agent {LIB_TESTS}.test_creation), "LIB_TESTS.test_creation")
		end

feature {NONE} -- Implementation

	report (a_result: EQA_PARTIAL_RESULT; a_name: STRING)
			-- Count and print `a_result' of test `a_name'.
		do
			if a_result.is_pass then
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			else
				print ("  FAIL: " + a_name + " [" + {UTF_CONVERTER}.string_32_to_utf_8_string_8 (a_result.tag) + "]%N")
				failed := failed + 1
			end
		end

end
