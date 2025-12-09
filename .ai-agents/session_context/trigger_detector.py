from typing import List

def detect_retrieval_triggers(user_message: str, agent_response: str) -> List[str]:
    """Detect which docs should be fetched based on message content."""

    triggers = []

    # Error pattern
    if any(word in user_message.lower() for word in ['error', 'failed', 'crash', 'bug']):
        triggers.append('TROUBLESHOOTING_CHECKLIST')

    # Deployment pattern
    if any(word in user_message.lower() for word in ['deploy', 'push', 'railway', 'production']):
        triggers.append('DEPLOYMENT_TRUTH')

    # Database pattern
    if any(word in agent_response.lower() for word in ['database', 'postgresql', 'sqlite', 'query']):
        triggers.append('STORAGE_PATTERNS')

    # Test pattern
    if any(word in user_message.lower() for word in ['test', 'pytest', 'golden']):
        triggers.append('TEST_FRAMEWORK')

    # Context overflow (agent struggling)
    if len(agent_response.split()) > 1000:
        triggers.append('CONTEXT_ENGINEERING_GUIDE')

    return triggers

if __name__ == '__main__':
    # Example usage and basic tests
    print("Running trigger detector tests...")

    # Test 1: Error trigger
    user_msg_1 = "I encountered an error trying to run the script."
    agent_resp_1 = "Attempting to fix the issue."
    expected_1 = ['TROUBLESHOOTING_CHECKLIST']
    result_1 = detect_retrieval_triggers(user_msg_1, agent_resp_1)
    print(f"Test 1 (Error): {'PASS' if result_1 == expected_1 else f'FAIL (Expected: {expected_1}, Got: {result_1})'}")

    # Test 2: Deployment trigger
    user_msg_2 = "Please deploy the changes to production."
    agent_resp_2 = "Initiating deployment process."
    expected_2 = ['DEPLOYMENT_TRUTH']
    result_2 = detect_retrieval_triggers(user_msg_2, agent_resp_2)
    print(f"Test 2 (Deployment): {'PASS' if result_2 == expected_2 else f'FAIL (Expected: {expected_2}, Got: {result_2})'}")

    # Test 3: Database trigger
    user_msg_3 = "Check the database logs."
    agent_resp_3 = "Querying the postgresql database for recent entries."
    expected_3 = ['STORAGE_PATTERNS']
    result_3 = detect_retrieval_triggers(user_msg_3, agent_resp_3)
    print(f"Test 3 (Database): {'PASS' if result_3 == expected_3 else f'FAIL (Expected: {expected_3}, Got: {result_3})'}")

    # Test 4: Test trigger
    user_msg_4 = "Run the pytest suite."
    agent_resp_4 = "Executing tests."
    expected_4 = ['TEST_FRAMEWORK']
    result_4 = detect_retrieval_triggers(user_msg_4, agent_resp_4)
    print(f"Test 4 (Test): {'PASS' if result_4 == expected_4 else f'FAIL (Expected: {expected_4}, Got: {result_4})'}")

    # Test 5: Context Overflow trigger (simulated)
    user_msg_5 = "Continue working on the task."
    agent_resp_5 = "This is a very long agent response to simulate context overflow. " * 1001 # Make it 1001 words to ensure len > 1000
    expected_5 = ['CONTEXT_ENGINEERING_GUIDE']
    result_5 = detect_retrieval_triggers(user_msg_5, agent_resp_5)
    print(f"Test 5 (Context Overflow): {'PASS' if result_5 == expected_5 else f'FAIL (Expected: {expected_5}, Got: {result_5})'}")

    # Test 6: Multiple triggers
    user_msg_6 = "There was an error during deployment. Please check logs and run tests."
    agent_resp_6 = "Checking logs and preparing for tests."
    expected_6 = ['TROUBLESHOOTING_CHECKLIST', 'DEPLOYMENT_TRUTH', 'TEST_FRAMEWORK']
    # Sort for consistent comparison as order might vary with `any()`
    result_6 = sorted(detect_retrieval_triggers(user_msg_6, agent_resp_6))
    print(f"Test 6 (Multiple): {'PASS' if result_6 == sorted(expected_6) else f'FAIL (Expected: {sorted(expected_6)}, Got: {result_6})'}")

    # Test 7: No triggers
    user_msg_7 = "Hello world."
    agent_resp_7 = "Hello to you too."
    expected_7 = []
    result_7 = detect_retrieval_triggers(user_msg_7, agent_resp_7)
    print(f"Test 7 (None): {'PASS' if result_7 == expected_7 else f'FAIL (Expected: {expected_7}, Got: {result_7})'}")

