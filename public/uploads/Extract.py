import google.generativeai as genai
from dotenv import load_dotenv
import os

load_dotenv()
GEMINI_API = os.getenv('API')

genai.configure(api_key=GEMINI_API)

file_path = os.path.join(os.path.dirname(__file__), 'english_output.txt')
output_file_path = os.path.join(os.path.dirname(__file__), 'extracted_details.json')

try:
    with open(file_path, 'r') as file:
        model = genai.GenerativeModel("gemini-1.5-flash")
        ThePrompt = file.read() + "\nExtract the details from the above text, such as name, parent's name, DOB, etc. Only print the detail and value pairs.Strictly in JSON format."
        response = model.generate_content(ThePrompt)

        # Check if the response contains valid content
        if response.parts:
            extracted_text = response.text
            with open(output_file_path, 'w') as output_file:
                output_file.write(extracted_text)
            print("Output written to 'extracted_details.txt'")
        else:
            print("No valid content returned. Check the safety ratings or other response properties.")
except FileNotFoundError:
    print(f"File '{file_path}' not found.")
except Exception as e:
    print(f"An error occurred: {e}")