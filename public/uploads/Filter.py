import os
import re

result_path = os.path.join(os.path.dirname(__file__), 'result.txt')
output_path = os.path.join(os.path.dirname(__file__), 'english_output.txt')

# Open the output file and read its contents
with open(result_path, 'r') as file:
    text = file.read()

# Define a regular expression to match English text
english_text = re.sub(r'[^\x00-\x7F]+', '', text)

# Write the filtered text to a new file
with open(output_path, 'w') as file:
    file.write(english_text)

print("English text has been extracted to 'english_output.txt'.")
