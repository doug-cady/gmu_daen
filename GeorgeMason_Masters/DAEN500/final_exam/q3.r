# Question 3 (R test)
#
# a) Create a vector of courses (MATH 101) you have taken previously.
#       Make sure you have at least 8 courses. Name the vector myCourses.
# b) Get the length of the vector myCourses
# c) Get the first two course from myCourses
# d) Get the 3rd and 4th courses from myCourses
# e) Sort myCourses using a method
# f) Sort myCourses in the reverse direction

myCourses <- c(
    'MATH 308',
    'MATH 311',
    'MATH 470',
    'CEEN 350',
    'CEEN 214',
    'CEEN 451',
    'CSCE 310',
    'CSCE 370',
    'CSCE 470'
)

print("1. length of myCourses:")
print(length(myCourses))

print("2. first two courses:")
print(myCourses[1:2])

print("3. 3rd and 4th courses")
print(myCourses[3:4])

print("4. sort my courses")
print(sort(myCourses))

print("5. sort in reverse direction")
print(sort(myCourses, decreasing=TRUE))
