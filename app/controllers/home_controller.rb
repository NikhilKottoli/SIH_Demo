class HomeController < ApplicationController
    def index
    end
  
    def data
    end
  
    def upload
      Rails.logger.info "Upload action started"
      Rails.logger.flush
  
      if params[:file].present?
        uploaded_file = params[:file]
        file_name = uploaded_file.original_filename
  
        # Set the save path to the root directory
        save_path = Rails.root.join("public", "uploads", file_name)
  
        begin
          # Save the file
          File.open(save_path, 'wb') do |file|
            file.write(uploaded_file.read)
          end
          Rails.logger.info "File successfully saved to #{save_path}"
          flash[:notice] = "File uploaded successfully to #{save_path}."
          # Perform OCR on the file
          ocr_result = perform_ocr(save_path,file_name)
  
          #refine data using AI
  
        rescue => e
          Rails.logger.error "Error saving file: #{e.message}"
          flash[:alert] = "There was an error uploading the file: #{e.message}"
        ensure
          # Ensure redirection happens regardless of whether there was an exception
          Rails.logger.info "Upload action ended"
          Rails.logger.flush
          redirect_to root_path
        end
      else
        Rails.logger.info "No file selected"
        flash[:alert] = "No file selected."
        Rails.logger.flush
        redirect_to root_path
      end
    end
  end
  
  
  def perform_ocr(file_path, output_file_name)
    tiff_path = Rails.root.join("public/uploads", "output.tiff")
  
    # Convert PDF to TIFF using 'magick'
    convert_command = "magick convert '#{file_path}' -fuzz 10% -fill none -draw 'color 0,0 floodfill' -density 300 -depth 8 -strip '#{tiff_path}'"

    Rails.logger.info "Running command: #{convert_command}"

    # Execute the command and capture the output
    output = `#{convert_command} 2>&1`
    Rails.logger.info "Convert command output: #{output}"

# After the image is prepared, you can use Tesseract for OCR
    
    unless File.exist?(tiff_path)
      Rails.logger.error "Conversion failed. No TIFF file found."
      return "Conversion failed. No TIFF file found."
    end
  
    # Perform OCR on the TIFF file
    output_text_file = Rails.root.join("public","uploads", "result")
    ocr_command = "tesseract '#{tiff_path}' '#{output_text_file}' -l eng"
    Rails.logger.info "Running command: #{ocr_command}"
    
    # Execute the command and capture the output
    ocr_output = `#{ocr_command} 2>&1`
    Rails.logger.info "Tesseract command output: #{ocr_output}"
    
    # Check if OCR was successful
    if File.exist?("#{output_text_file}.txt")
      File.read("#{output_text_file}.txt")
    else
      Rails.logger.error "OCR failed. No output text file found."
      "OCR failed. No output text file found."
    end
  
    # Run the Python scripts
    run_python_scripts
  end
  
  
  def run_python_scripts
    # Define the paths to the scripts
    extract_script = Rails.root.join("public", "uploads", "extract.py")
    filter_script = Rails.root.join("public", "uploads", "filter.py")
    crop = Rails.root.join("public", "uploads", "crop.py")
    
    # Path to the virtual environment's Python interpreter
    venv_python = Rails.root.join("venv", "bin", "python3")
    
    # Command to run the extract script
    extract_command = "#{venv_python} '#{extract_script}'"
    filter_command = "#{venv_python} '#{filter_script}'"
  
     # Run the filter script
     Rails.logger.info "Running filter script: #{filter_command}"
     filter_output = `#{filter_command} 2>&1`
     Rails.logger.info "Filter script output: #{filter_output}"
    
    # Run the extract script
    Rails.logger.info "Running extract script: #{extract_command}"
    extract_output = `#{extract_command} 2>&1`
    Rails.logger.info "Extract script output: #{extract_output}"

    crop_command = "#{venv_python} '#{crop}'"
    Rails.logger.info "Running crop script: #{crop_command}"
    crop_output = `#{crop_command} 2>&1`
    Rails.logger.info "Crop script output: #{crop_output}"
    
    
    # Check if both scripts executed successfully
    if $?.success?
      Rails.logger.info "Both scripts ran successfully."
    else
      Rails.logger.error "One or both scripts failed."
    end
  end
  
  