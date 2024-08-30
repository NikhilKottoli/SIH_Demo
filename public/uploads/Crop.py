import os
import re

# Define file paths
input_file_path = os.path.join(os.path.dirname(__file__), 'extracted_details.json')
output_file_path = os.path.join(os.getcwd(),'public', 'output.json')

def clean_and_truncate_file(input_file_path, output_file_path):
    try:
        with open(input_file_path, 'r') as input_file:
            content = input_file.read()
            
            # Remove leading ```json and trailing ```
            content = re.sub(r'^```json\s*', '', content)
            content = re.sub(r'\s*```$', '', content)

            # Find the first occurrence of the closing brace and truncate content after it
            end_index = content.find('}')
            if end_index != -1:
                content = content[:end_index + 1]  # Include the closing brace
            
            # Write cleaned content to the output file
            with open(output_file_path, 'w') as output_file:
                output_file.write(content)
        
        print(f"Content cleaned and written to '{output_file_path}'.")

    except FileNotFoundError:
        print(f"File '{input_file_path}' not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

# Call the function to clean and truncate the file
clean_and_truncate_file(input_file_path, output_file_path)
