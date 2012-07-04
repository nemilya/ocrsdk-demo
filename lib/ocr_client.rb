# based on:
# https://github.com/abbyysdk/ocrsdk.com/blob/master/Ruby/abbyy_ruby_example.rb

# OCR SDK Ruby sample
# Documentation available on http://ocrsdk.com/documentation/

# IMPORTANT!
# Make sure you have rest-client (see https://github.com/archiloque/rest-client for detaile) gem installed or install it:
#    gem install rest-client

require "rexml/document"

# IMPORTANT!
# Provide your OCR SDK ApplicationID and Password here

# IMPORTANT!
# Specify path to image file you want to recognize
# FILE_NAME = "New Image.JPG"

# IMPORTANT!
# Specify recognition languages of document. For full list of available languaes see
# http://ocrsdk.com/documentation/apireference/processImage/
# Examples: 
#   English
#   English,German
#   English,German,Spanish
# LANGUAGE = "English"

# OCR SDK base url with application id and password

module AbbySDK
  class OCR

    # Routine for OCR SDK error output
    def self.output_response_error(response)
      # Parse response xml (see http://ocrsdk.com/documentation/specifications/status-codes)
      xml_data = REXML::Document.new(response)
      puts "Error: #{xml_data.elements["error/message"].text}" if xml_data.elements["error/message"]
    end

    def self.base_url(app_id, pwd)
      require "cgi"
      pwd = CGI.escape(pwd)
      "http://#{app_id}:#{pwd}@cloud.ocrsdk.com"
    end

    # register image for recognition
    #
    # return task_id
    def self.start_process_image(app_id, pwd, lang, file_path)
      task_id = nil
      base_url = self.base_url(app_id, pwd)
      begin
        response = RestClient.post("#{base_url}/processImage?language=#{lang}&exportFormat=txt", :upload => { 
          :file => File.new(file_path, 'rb') 
        })  
      rescue RestClient::ExceptionWithResponse => e
        # Show processImage errors
        self.output_response_error(e.response)
        raise
      else
        # Get task id from response xml to check task status later
        xml_data = REXML::Document.new(response)
        task_id = xml_data.elements["response/task"].attributes["id"]
      end
      task_id
    end

    # request task processing state
    #
    def self.get_task_state(app_id, pwd, task_id)
      ret = {}
      ret[:state] = nil
      ret[:download_url] = nil

      base_url = self.base_url(app_id, pwd)
      begin
        # Call the getTaskStatus function (see http://ocrsdk.com/documentation/apireference/getTaskStatus)
        response = RestClient.get("#{base_url}/getTaskStatus?taskid=#{task_id}")
      rescue RestClient::ExceptionWithResponse => e
        # Show getTaskStatus errors
        self.output_response_error(e.response)
        raise
      else
        # Get the task status from response xml
        xml_data = REXML::Document.new(response)
        task_status = xml_data.elements["response/task"].attributes["status"]
        ret[:state] = task_status
        if task_status == "Completed"
          ret[:download_url] = xml_data.elements["response/task"].attributes["resultUrl"]
        end
      end
      ret
    end


    # long-time function
    #
    def self.process_image(app_id, pwd, lang, file_path)
      base_url = self.base_url(app_id, pwd)

      # Upload and process the image (see http://ocrsdk.com/documentation/apireference/processImage)
      # puts "Image will be recognized with #{LANGUAGE} language."
      # puts "Uploading file.."
      begin
        response = RestClient.post("#{base_url}/processImage?language=#{lang}&exportFormat=txt", :upload => { 
          :file => File.new(file_path, 'rb') 
        })  
      rescue RestClient::ExceptionWithResponse => e
        # Show processImage errors
        self.output_response_error(e.response)
        raise
      else
        # Get task id from response xml to check task status later
        xml_data = REXML::Document.new(response)
        task_id = xml_data.elements["response/task"].attributes["id"]
      end

      # Get task information in a loop until task processing finishes
      # puts "Processing image.."
      begin
        # Make a small delay
        sleep(0.5)
        
        # Call the getTaskStatus function (see http://ocrsdk.com/documentation/apireference/getTaskStatus)
        response = RestClient.get("#{base_url}/getTaskStatus?taskid=#{task_id}")
      rescue RestClient::ExceptionWithResponse => e
        # Show getTaskStatus errors
        self.output_response_error(e.response)
        raise
      else
        # Get the task status from response xml
        xml_data = REXML::Document.new(response)
        task_status = xml_data.elements["response/task"].attributes["status"]
        
        # Check if there were errors ..
        raise "The task hasn't been processed because an error occurred" if task_status == "ProcessingFailed"
        
        # .. or you don't have enough credits (see http://ocrsdk.com/documentation/specifications/task-statuses for other statuses)
        raise "You don't have enough money on your account to process the task" if task_status == "NotEnoughCredits"
      end until task_status == "Completed"

      # Get the result download link
      download_url = xml_data.elements["response/task"].attributes["resultUrl"]

      # Download the result
      # puts "Downloading result.."
      recognized_text = RestClient.get(download_url)

      # We have the recognized text - output it!
      return recognized_text
    end
  end
end