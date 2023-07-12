"""
TDD web app with Django, Selenium, and Python

Part 1 - Getting Django set up using a functional test

"""

from selenium import webdriver
from selenium.common.exceptions import TimeoutException

browser = webdriver.Firefox()
try:
    # browser.set_page_load_timeout(30)
    # browser.implicitly_wait(10)
    browser.get("http://localhost:8000")
except TimeoutException as ex:
    isrunning = 0
    print(f"Exception has been thrown. {str(ex)}")
    browser.close()

assert "Django" in browser.title
