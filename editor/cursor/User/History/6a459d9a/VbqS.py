# ( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)
# =======================================================
# === Written by..: Joseph LoVerso                   ====
# === Date Began Writing: 03/01/2025                 ====
# === Date Finished.....: 03/11/2025                 ====
# === Purpose.....: Automate Canvas Quiz & Assignment Grading ====
# =======================================================
# ( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)

import time
import platform
import shutil
import os
import requests
import json
from typing import Tuple
import re
# Sync_playwright is a context manager that allows you to launch a browser and interact with web pages.
from playwright.sync_api import Playwright, sync_playwright, expect

# Random is for randomizing wait times to avoid any bot detectors
import random

# Allows password masking
from getpass import getpass

def main(): # Welcome user and introduce the script
    welcome()
    # Begin by getting user inputs before launching the browser
    user_credentials = get_user_credentials()
    with sync_playwright() as p:
        # Main function is occurring within a try statement to catch any errors that may occur.``
        try:
            chrome_path = detect_chrome_path()
            browser = p.chromium.launch(
                headless=False,
                slow_mo=1000,
                executable_path=chrome_path,
            )
            page = browser.new_page()
            # Call your functions
            sign_in(page, user_credentials)
            assignments = get_urls()

            for i, assignment in enumerate(assignments):
                current_assignment_url = assignment["url"]
                canvas_type = assignment["type"]

                navigate_to_speedgrader(page, i, current_assignment_url)
                set_up_speedgrader(page)  # This is common for both types

                if canvas_type == "new_quiz":
                    # Your existing New Quiz grading code
                    needs_grading = True
                    while needs_grading:
                        needs_grading = check_if_student_has_submission(page)
                        if not needs_grading:
                            break

                        # Get list of questions that need grading
                        questions_found, grading_decisions = (
                            find_questions_need_grading(page)
                        )

                        # Process questions if any are found
                        if len(questions_found) > 0:
                            try:
                                # Find student answers and make grading decisions
                                grading_decisions = find_student_answers(
                                    page, questions_found, grading_decisions, 0
                                )

                                # Mark questions based on the grading decisions
                                mark_questions(page, questions_found, grading_decisions)
                                submit_student_grade(page)
                            except Exception as e:
                                print(f"Error during grading process: {str(e)}")
                        else:
                            print(
                                "No questions found to grade. Moving to next student..."
                            )

                        navigate_to_next_student(page)

                elif canvas_type == "assignment":
                    # Use the new assignment grading workflow
                    grade_assignment_workflow(page)

        except Exception as e:
            print(f"An error occurred: {str(e)}")
            if page:
                page.pause()  # Allow for user inspection
        finally:
            # Close up the shop
            print("Script successfully completed.")
            if browser:
                browser.close()

def detect_chrome_path():
    """
    Return the path to your Chrome/Chromium binary based on the host OS.
    Falls back to looking on PATH via shutil.which().
    """
    system = platform.system()
    if system == "Linux":
        # common distro path
        candidates = ["/usr/bin/chromium-browser", "/usr/bin/chromium"]
    elif system == "Darwin":
        # Homebrew‑installed Chromium on Apple Silicon
        candidates = ["/opt/homebrew/bin/chromium", "/usr/local/bin/chromium"]
    elif system == "Windows":
        # 64‑bit Chrome on Win10/11
        candidates = [r"C:\Program Files\Google\Chrome\Application\chrome.exe"]
    else:
        raise RuntimeError(f"Unsupported OS: {system}")

    # first try your hard‑coded locations
    for path in candidates:
        if os.path.isfile(path):
            return path

    # otherwise, try to find any chrome/chromium on PATH
    for exe in ["chromium-browser", "chromium", "google-chrome", "chrome"]:
        which_path = shutil.which(exe)
        if which_path:
            return which_path

    raise FileNotFoundError(
        "Could not find Chromium/Chrome executable on this machine."
    )

# Welcomes the user to the script
def welcome():
    print(
        "Welcome to the Canvas Grading Automation Script!\nThis script is designed to automate the grading of NEW quizzes and Assignments in Canvas.\nMake sure you select the correct type for each assignment you want to grade."
    )

def get_user_credentials():
    username = input("Enter your Canvas username: ")
    password = getpass("Enter your Canvas password: ")
    MFACode = input("Enter your Canvas MFA code: ")
    return {"username": username, "password": password, "MFACode": MFACode}

def humanizer(min_wait=1, max_wait=2):
    # random wait time to ensure page is fully loaded
    random_integer = random.randint(min_wait, max_wait)
    time.sleep(random_integer)

def sign_in(page, user_inputs):
    username = user_inputs["username"]
    password = user_inputs["password"]
    MFACode = user_inputs["MFACode"]
    try:
        # Login sequence
        print("Navigating to login page...")
        page.goto(
            "https://ocps.instructure.com/login/saml",
            wait_until="networkidle",
            timeout=30000,
        )
        # Username field interaction
        page.get_by_label("Username").fill(username)
        page.get_by_label("Password", exact=True).fill(password)
        page.get_by_label("Sign In", exact=True).click()
        print("Sign-in successful.\nProceeding to MFA...")
        humanizer()

        # MFA code field interaction
        page.get_by_placeholder("Code").fill(MFACode)
        page.get_by_role("button").click()

        print("Proceeding after authentication...")
        humanizer()
        while True:
            try:
                expect(page).to_have_url(
                    "https://ocps.instructure.com/?login_success=1"
                )
                break
            except Exception as e:
                print(f"An error occurred during sign-in\n Error details: {str(e)}")
                print(
                    "Please manually enter MFA code.\nResume script after successful sign-in."
                )
                page.pause()
        print("Successfully logged in!")
        humanizer(8, 10)
    except Exception as e:  # Catch any errors that occur during sign-in
        print("An error occurred during sign-in")
        print(f"Error details: {str(e)}")
        page.pause()  # Pause script for manual inspection by user

# For new quiz & assignment
def get_urls():
    assignments = [] # Create a list to store assignments with their types(new_quiz or assignment)

    # Ask for first URL
    url = input("Enter the URL of the assignment to grade: ")

    while True:
        # Ask for type
        is_new_quiz = input("Is this a New Quiz? (y/n): ")
        canvas_type = (
            "new_quiz" if is_new_quiz.strip().lower() == "y" else "assignment"
        )
        # Create assignment dict
        assignment = {"url": url, "type": canvas_type}
        
        # AI prompts for new quiz:
        if is_new_quiz.strip().lower() == "y":
            ai_mode = get_ai_grading_choice()
            assignment["ai_mode"] = ai_mode  # Store AI mode in assignment dict
            
        # Add to assignments list
        assignments.append(assignment)

        # Ask if user wants to add another assignment
        add_url = input("Do you have another assignment to grade? (y/n): ")
        if add_url.strip().lower() == "y":
            url = input("Enter the URL of the assignment to grade: ")
        elif add_url.strip().lower() == "n":
            break
        else:
            print("Please enter y or n")

    print(f"Grading {len(assignments)} assignments")
    return assignments

# For new quiz
def get_ai_grading_choice():
    """
     Get the AI grading mode from the user.
    
    Returns:
        Union[NullAIMode, NiceGuyAIMode, BookAIMode]: A dictionary containing:
            - For no AI grading: {"mode": "null"}
            - For Mr. NiceGuy with target: {"mode": "niceguy", "target_q": int}
            - For Mr. BytheBook: {"mode": "book"}
    """
    ai_mode = {} # Create a dictionary to store the AI grading mode and target question
    while True:
        choice = input("Would you like to grade with AI? (y/n): ")
        if choice.strip().lower() == "n":
            ai_mode["mode"] = "null"
            return ai_mode # Return the null mode
        else:
            while True:
                choice = input("How do you want to grade with AI? Press (n) for Mr. NiceGuy or (b) for Mr.BytheBook book). Press n or b and hit enter: ")
                if choice.strip().lower() == "n":
                    print("Mr.NiceGuy will grade all questions LENIENTLY.")
                target_q = input("Would you like him to target a specific question for him to provide feedback on? (y/n): ")
                if target_q.strip().lower() == "y":
                    while True:
                        target_q = input("Which question number would you like him to target? Please enter the number: ")
                        try: 
                            target_q = int(target_q)
                            if target_q > 0 and target_q <= 30:
                                    ai_mode["mode"] = "niceguy"
                                    ai_mode["target_q"] = target_q
                                    return ai_mode
                            else:
                                    print("ERROR: please enter a valid question number.")
                                    continue
                        except ValueError:
                            print("ERROR: please enter a valid question number.")
                            continue
                elif choice.strip().lower() == "b":
                    ai_mode["mode"] = "book"
                    return ai_mode
                else:
                    print("ERROR: Please enter (n) or (b) and hit enter.")
                    continue


# For New Quiz questions
def ai_grade_answer_new_quiz(question: str, answer: str) -> bool:
    """
    Uses google/gemini‑flash‑2.5 preview on OpenRouter to judge correctness.
    The model must answer ONLY 'true' or 'false'.
    """
    headers = {
        # Open Router API key
        "Authorization": "Bearer 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",
        "Content-Type": "application/json",
    }
    payload = {
        "model": "google/gemini-2.5-flash-preview",
        "temperature": 0,
        "messages": [
            {
                "role": "system",
                "content": (
                    "You are a lenient teacher with students who are low level readers."
                    "You are grading classwork for completion credit not 'correctness'."
                    "Return just the word 'true' if the student answer is expected from a 10th grader with very low reading ability."
                    "Stimulus relevant for knowing the correct answer has not been provided."
                    "Simply determine if the answer is a good try.  Otherwise return 'false'."
                    "No other text."
                ),
            },
            {
                "role": "user",
                "content": f"Question: {question}\nStudent answer: {answer}",
            },
        ],
    }
    try:
        r = requests.post(
            "https://openrouter.ai/api/v1/chat/completions",
            headers=headers,
            json=payload,
            timeout=30,
        )
        reply = r.json()["choices"][0]["message"]["content"].lower().strip()
        # Accept "true", "true.", "true ✅", etc.  Anything else counts as False.
        if re.match(r"^true\b", reply):
            return True

        
        elif re.match(r"^false\b", reply):
            return False
        else:
            # unexpected output – fall back to participation credit
            print(f"⚠️ AI returned something unexpected: {reply!r}")
            return True # We'll be generous if the call fails
    except Exception as e:
        print(f"Error during AI grading: {e}")
        return True # We'll be generous if the call fails

# For new quiz & assignment
def navigate_to_speedgrader(page, assignment_numb, current_assignment_url):
    print(
        f"Opening Speedgrader for assignment {assignment_numb + 1}\nurl = {current_assignment_url}"
    )

    try:
        # Navigate with longer timeout and wait until network is idle
        page.goto(current_assignment_url, wait_until="networkidle", timeout=30000)
        print("Page loaded, waiting for content to stabilize...")
        humanizer(9, 10)

        # Wait for key elements that indicate the page is ready
        page.wait_for_selector(
            "#speedgrader_iframe", state="attached", timeout=20000
        )
        page.wait_for_selector(
            "#students_selectmenu-button", state="visible", timeout=20000
        )

        print("Navigation complete, page appears stable")

    except Exception as e:
        print(f"Warning during navigation: {e}")
        # If there's an error, give extra time for recovery
        page.pause()  # Kill script to allow user inspection
        humanizer(12, 15)

# For new quiz
def ensure_answers_accessible(page):
    try:
        # First scroll to top of page
        page.evaluate("window.scrollTo(0, 0)")
        print("Scrolled to top of page")

        # Then click the Results header
        Results_header = (
            page.frame_locator("#speedgrader_iframe")
            .get_by_test_id("test-head-title")
            .get_by_text("Results")
        )
        Results_header.click()
        print("Clicked Results header")

        # Then reload the page
        page.reload()
        humanizer(3, 4)

        # After reload, click Results header again
        frame = page.frame_locator("#speedgrader_iframe")
        Results_header.click()

        # Find first available question (checking questions 1-20)
        for i in range(1, 20):
            question_selector = frame.get_by_role(
                "link", name=f"Question {i}", exact=True
            )
            if question_selector.count() > 0:
                question_selector.click()

                # Verify answers are accessible
                answers = frame.locator(".user_content.css-bapbco.enhanced")
                answers.all()
                return True
        return False
    except Exception:
        return False


# For new quiz & assignment
def set_up_speedgrader(page):
    print("Setting up Speedgrader sorting preferences...")
    # Setup student menu with verification
    try:
        students_menu = page.locator("#students_selectmenu-button")
        students_menu.click()
        print("Clicked students menu")

        # Wait for sections option and verify it's visible
        humanizer(1, 2)
        sections_option = page.get_by_role("option", name="Showing: All Sections")
        sections_option.hover()

        humanizer(1, 2)
        all_sections = page.get_by_role("menuitem", name="Show All Sections")
        all_sections.wait_for(state="visible", timeout=10000)
        all_sections.click()
        print("Selected all sections")

        # Extended wait after sections change
        humanizer(8, 10)

        # Settings setup with verification
        settings_button = page.get_by_role("button", name="Settings")
        settings_button.click()
        print("Opened settings")

        humanizer()
        options_button = page.get_by_label("Options", exact=True)
        options_button.click()

        sort_dropdown = page.get_by_label("Sort student list")
        sort_dropdown.select_option("submission_status")
        print("Changed sort settings")
        save_button = page.get_by_role("button", name="Save Settings")
        save_button.click()
        print("Saved settings")
        humanizer()

        # For new quizzes, ensure answers are accessible
        try:
            # Click Results heading
            Results_header = (
                page.frame_locator("#speedgrader_iframe")
                .get_by_test_id("test-head-title")
                .get_by_text("Results")
            )
            Results_header.click()

            # Try to ensure answers are accessible with a maximum number of attempts
            max_attempts = 3
            attempt = 0
            while not ensure_answers_accessible(page):
                print(
                    f"Attempt {attempt + 1}/{max_attempts} to ensure answers are accessible"
                )
                attempt += 1
                if attempt >= max_attempts:
                    print(
                        "Failed to ensure answers are accessible after maximum attempts"
                    )
                    print("This usually means the page is in a deficient state")
                    print("Please inspect the page and check if:")
                    print("1. The Results header is visible")
                    print("2. Question 1 is visible")
                    print("3. The page styling appears normal")
                    page.pause()  # Let user inspect the issue
                    break
                print("Waiting before next attempt...")
                humanizer(2, 3)  # Wait between attempts
        except Exception as e:
            # This might be an assignment that doesn't have Results header
            print(f"    Error: {e}")
            print("Note: Results header not found - likely an assignment.")

        # Extended final wait to ensure all changes are processed
        print("Waiting for page to fully stabilize...")
        humanizer(10, 11)

    except Exception as e:
        print(f"Warning during speedgrader setup: {e}")
        # Give extra time to recover if there was an error
        humanizer(20, 25)

    print("Speedgrader setup complete.")

# For new quiz
def find_questions_need_grading(page):
    print("Identifying quiz questions...")
    questions_found = []
    grading_decisions = {}
    frame_locator = page.frame_locator("#speedgrader_iframe")
    # Look for questions with improved error handling
    print("Scanning for quiz questions...")
    for i in range(1, 30):  # Limit to 30 questions for efficiency
        try:
            question_selector = frame_locator.get_by_role(
                "link", name=f"Question {i}", exact=True
            )

            # More thorough visibility check
            if question_selector.count() > 0:
                questions_found.append(i)
                print(f"Found question {i}")
        except Exception as e:
            # If we hit an error, we've likely checked all questions
            break

    # Print the total number of questions found
    print(f"Total questions identified: {len(questions_found)}")
    # Initialize grading decisions dictionary and set all to "correct" by default
    for question_number in questions_found:
        grading_decisions[question_number] = "correct"

    return questions_found, grading_decisions

# For new quiz
def find_student_answers(page, questions_found, grading_decisions, reload_counter):
    print("Searching for student answers…")

    # If no questions to grade, bail out early
    if not questions_found:
        print("No questions to process")
        return grading_decisions

    # Always target the SpeedGrader iframe by its CSS ID
    frame = page.frame_locator("#speedgrader_iframe")

    try:
        # 1) Click the first question link to ensure SpeedGrader is open
        first_q = questions_found[0]
        q_link = frame.get_by_role("link", name=f"Question {first_q}", exact=True)
        if q_link.count() == 0:
            print(f"Question {first_q} link not found")
            return grading_decisions
        print(f"  Clicking Question {first_q}")
        q_link.click()

        # 2) Scope into the Quiz content region
        quiz_region = frame.get_by_role("region", name="Quiz content")
        quiz_region.wait_for(state="visible")

        # 3) Extract each prompt & answer
        questions = []
        student_answers = []

        for qnum in questions_found:
            # click the link again to load the wrapper for this question
            frame.get_by_role("link", name=f"Question {qnum}", exact=True).click()

            # locate the wrapper by matching its question text
            wrapper = quiz_region.locator(
                f"div[data-automation='sdk-grading-result-wrapper']:has-text('Question {qnum}')"
            ).first
            wrapper.wait_for(state="visible")

            # grab the two RCE blocks (prompt + maybe answer)
            blocks = wrapper.locator("div.user_content.enhanced")
            q_text = blocks.nth(0).inner_text().strip()
            if blocks.count() > 1:
                a_text = blocks.nth(1).inner_text().strip()
            else:
                a_text = "(no answer)"

            questions.append(q_text)
            student_answers.append(a_text)

        # 4) Debug print of what we grabbed
        for q, a in zip(questions, student_answers):
            print("Q:", q)
            print("A:", a)
            print("---")

        # 5) If we found any answers, make AI call if user requested, else give participation credit 
        for qnum, (q_text, a_text) in enumerate(zip(questions, student_answers), start=1):
            should_use_ai = (
                ai_mode == "all"
                or (ai_mode == "one" and qnum == ai_target_q)
            )

            if a_text == "(no answer)":
                grading_decisions[qnum] = "incorrect"
            elif should_use_ai:
                correct = ai_grade_answer(q_text, a_text)
                grading_decisions[qnum] = "correct" if correct else "incorrect"
            else:                         # participation credit
                grading_decisions[qnum] = "correct"

        return grading_decisions

    except Exception as e:
        print(f"  Error processing answers: {e}")
        page.pause()

    # 6) Only reaches here if no answers were found (or we hit an exception)
    if reload_counter >= 3:
        print("Failure after 3 reload attempts. Please manually inspect")
        page.pause()
    else:
        print("    Warning: No answers found, reloading…")
        reload_counter += 1
        if ensure_answers_accessible(page):
            print("    Page restored to proper state, retrying")
            return find_student_answers(
                page, questions_found, grading_decisions, reload_counter
            )
        else:
            print("    Failed to restore page state")
            page.pause()

    return grading_decisions

def get_grading_buttons(page, questions_found):
    print("\nMapping grading buttons to questions...")
    frame = page.frame_locator("#speedgrader_iframe")
    button_map = {}

    try:
        # Click the first question to make all buttons visible
        first_question = questions_found[0]
        question = frame.get_by_role(
            "link", name=f"Question {first_question}", exact=True
        )
        if question.count() > 0:
            print(f"  Clicking Question {first_question} to reveal buttons")
            question.wait_for(state="visible", timeout=10000)
            question.focus()
            question.click()
            humanizer(1, 2)  # Wait for buttons to become visible

            # Get all grading buttons
            all_buttons = frame.locator("button:has-text('toggle'):visible").all()
            print(f"    Found {len(all_buttons)} total grading buttons")

            # Map button pairs to questions
            current_question = 0
            for i in range(0, len(all_buttons), 2):
                if current_question < len(questions_found) and i + 1 < len(
                    all_buttons
                ):
                    question_number = questions_found[current_question]
                    button_map[question_number] = {
                        "correct": all_buttons[i],
                        "incorrect": all_buttons[i + 1],
                    }
                    print(f"    Mapped button pair for Question {question_number}")
                    current_question += 1
                else:
                    break

    except Exception as e:
        print(f"  Error mapping grading buttons: {e}")

    return button_map

def mark_correct(page, question_number, button_map):
    try:
        if question_number in button_map:
            print(
                f"  Clicking 'toggle correct on' button for question {question_number}"
            )
            correct_button = button_map[question_number]["correct"]
            correct_button.wait_for(state="visible", timeout=10000)
            correct_button.click()
            page.wait_for_timeout(1000)  # Give UI time to update
        else:
            print(f"  No correct button found for question {question_number}")
    except Exception as e:
        print(f"  Error marking question {question_number} as correct: {str(e)}")

def mark_incorrect(page, question_number, button_map):
    try:
        if question_number in button_map:
            print(
                f"  Clicking 'toggle incorrect on' button for question {question_number}"
            )
            incorrect_button = button_map[question_number]["incorrect"]
            incorrect_button.wait_for(state="visible", timeout=10000)
            incorrect_button.click()
            page.wait_for_timeout(1000)  # Give UI time to update
        else:
            print(f"  No incorrect button found for question {question_number}")
    except Exception as e:
        print(f"  Error marking question {question_number} as incorrect: {str(e)}")

def mark_questions(page, questions_found, grading_decisions):
    # Get button pairs mapped to questions
    button_map = get_grading_buttons(page, questions_found)

    # For each detected question
    for question_number in questions_found:
        print(f"Processing Question {question_number}...")

        try:
            if question_number in button_map:
                if grading_decisions[question_number] == "correct":
                    mark_correct(page, question_number, button_map)
                elif grading_decisions[question_number] == "incorrect":
                    mark_incorrect(page, question_number, button_map)
            else:
                print(f"  No grading decision found for question {question_number}")

        except Exception as e:
            print(f"Error processing question {question_number}: {str(e)}")

    # compare_answers_to_test_case(grading_decisions)
    print("Finished processing all questions!")

def submit_student_grade(page):
    # After processing all questions, click the Update button to finalize grading
    print("\nAttempting to finalize grades by clicking the Update button...")
    # Define frame_locator
    frame_locator = page.frame_locator("#speedgrader_iframe")
    try:
        # Look specifically for an Update button as identified in the Playwright inspector
        update_button = frame_locator.get_by_role("button", name="Update")

        if update_button.count() > 0:
            print("Found 'Update' button...")
            update_button.wait_for(state="visible", timeout=10000)
            update_button.focus()
            update_button.click()
            page.wait_for_timeout(2000)  # Wait for the update to complete
            print("Grades updated successfully!")
        else:
            update_clicked = False

            if not update_clicked:
                print(
                    "WARNING: Could not find any Update button to finalize grades."
                )
                print("Manually inspect page...")
                page.pause()

    except Exception as e:
        print(f"Error when trying to finalize grades: {str(e)}")
        print("Manually inspect page...")
        page.pause()

# After updating grades, proceed to the next student if available
def navigate_to_next_student(page):
    # Define frame_locator
    frame_locator = page.frame_locator("#speedgrader_iframe")
    print("\nAttempting to move to the next student...")
    next_button = page.get_by_label("Next")
    next_button.click()
    print("\nNavigated to next student")
    
def check_if_student_has_submission(page):
    # Adjust random wait time to ensure page is fully loaded- this feature has bugged before.
    humanizer(2, 3)
    # Define frame_locator
    frame_locator = page.frame_locator("#speedgrader_iframe")

    print("Checking if student has a submission...")

    try:
        # Check if the "no submission" heading exists
        no_submission_element = page.get_by_role(
            "heading", name="This student does not have a"
        )

        if no_submission_element.count() > 0:
            has_submission = False
            print("Student does not have a submission\nNo more students to grade.")
        else:
            has_submission = True
            print("Student has a submission")

    except Exception as e:
        # If there's an error, log it and assume student has a submission
        print(f"Error checking if student has a submission: {str(e)}")
        has_submission = True
        print("Assuming student has a submission due to error")

    return has_submission
    
# New function for handling assignment grading workflow
def grade_assignment_workflow(page):
    print("Starting assignment grading workflow...")

    # First student - extract the total points possible
    points_possible = None

    try:
        # Extract points on first run
        grade_out_of_element = page.get_by_text("Grade out of")

        if grade_out_of_element.count() > 0:
            grade_text = grade_out_of_element.text_content()
            print(f"Found text: '{grade_text}'")  # Debug output

            # Use regular expression to find the number more reliably
            import re

            points_match = re.search(r"\d+\.?\d*", grade_text)

            if points_match:
                points_possible = float(points_match.group(0))
                print(f"Assignment is worth {points_possible} points")
            else:
                print(
                    "Could not extract points from text, prompting for manual entry"
                )
                points_possible = float(
                    input("Enter the total points for this assignment: ")
                )
        else:
            print("Could not find points information, prompting for manual entry")
            points_possible = float(
                input("Enter the total points for this assignment: ")
            )

        # Now begin the grading loop
        needs_grading = True
        while needs_grading:
            needs_grading = check_if_student_has_submission(page)
            if not needs_grading:
                print("No more students to grade for this assignment.")
                break

            # Grade the current student
            grade_current_student(page, points_possible)

            # Move to next student
            navigate_to_next_student(page)
            humanizer(2, 3)  # Allow page to load

    except Exception as e:
        print(f"Error during assignment grading workflow: {str(e)}")
        print("Please manually complete the grading, then continue")
        page.pause()

# Function to grade an individual student assignment
def grade_current_student(page, points_possible):
    try:
        print(f"Entering grade: {points_possible}")

        # Find and fill the grade input field
        grade_input = page.get_by_role("textbox", name="Grade out of")
        if grade_input.count() > 0:
            grade_input.click()  # Focus
            grade_input.fill(str(points_possible))  # Fill
            humanizer(1, 2)  # Wait for input to register
        else:
            print("Could not find grade input field")
            print("Please manually enter the grade and then continue")
            page.pause()

        # Submit the grade
        submit_button = page.get_by_role("button", name="Submit")
        if submit_button.count() > 0:
            print("Clicking Submit button...")
            submit_button.click()
            humanizer(2, 3)  # Wait for submission to process
            print("Grade submitted successfully")
        else:
            print("Could not find Submit button")
            print("Please manually submit the grade and then continue")
            page.pause()

    except Exception as e:
        print(f"Error grading student: {str(e)}")
        print("Please complete grading manually, then continue")
        page.pause()



# Call the main function to run the script
main()
# ( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)
# =========================================================================================


