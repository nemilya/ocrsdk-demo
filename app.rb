require "rubygems"

require "sinatra"
require "yaml"
require "rest_client"
require "cgi"

require "lib/ocr_client.rb"

require "helpers.rb"

before do
  @picture_samples = YAML.load(File.open("config/picture_samples.yml").read)
  @ocr_sdk = YAML.load(File.open("config/ocr_sdk.yml").read)
end

get "/" do
  @languages = @picture_samples.keys.sort
  @files = get_files_of_lang_with_size(params[:lang]) if params[:lang]
  erb :index
end

get "/do_ocr" do
  lang = params[:lang]
  file_path = params[:file_path]
  if lang && get_files_path(lang).include?(file_path)
#    ocr_result = get_ocr_of_file(lang, file_path)
    task_id = start_process_image(lang, file_path)
    redirect "/task_state?task_id=#{task_id}"
  else
    redirect "/"
  end
end

get "/task_state" do
  task_id = params[:task_id]
  @task_info = get_task_state(task_id)
  erb :task_state
end