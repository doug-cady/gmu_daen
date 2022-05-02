"""
Design and implement a Python program that is based on the following requirements:
a) define a class which has at least two methods
    ◦ Method 1 – getString: to get a string from console input; and,
    ◦ Method 2 - printString: to print the string in upper case.
b) demonstrate code works using three different test input strings
"""

class Baby:
    def __init__(self, name: str, age_months: int):
        self.name = name
        self.age_months = age_months

    def getString(self) -> str:
        """ Gets a string from console input """
        return input("Enter a string to make uppercase: \n")

    def printString(self) -> None:
        """ Prints command line argument in upper case """
        print(self.getString().upper())


if __name__ == '__main__':
    MyBaby = Baby(name='Gabby', age_months=4)
