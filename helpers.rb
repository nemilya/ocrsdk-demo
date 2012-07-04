helpers do
  def get_languages
    @picture_samples.keys.sort
  end

  def get_files_of_lang(lang)
    if get_languages.include?(lang)
      return @picture_samples[lang]["files"]
    end
    nil
  end

  def get_files_of_lang_with_size(lang)
    files = get_files_of_lang(lang)
    files.each do |file|
      file["size"] = File.size(get_real_file_path(lang, file["path"]))
    end
    files
  end

  def size_in_mb(size_in_bytes)
    "%0.2f Mb" % (size_in_bytes.to_f / (1024.0 * 1024.0))
  end

  def get_files_path(lang)
    get_files_of_lang(lang).map{|f| f["path"]}
  end

  def get_web_path(lang, file_path)
    file_path = CGI.escape(file_path)
    "/picture_samples/#{lang}/#{file_path}"
  end

  def get_real_file_path(lang, file_path)
    "./public/picture_samples/#{lang}/#{file_path}"
  end

  # return task id
  def start_process_image(lang, file_path)
    real_file_path = get_real_file_path(lang, file_path)

    app_id = @ocr_sdk["ocr_sdk"]["app_id"]
    pwd =  @ocr_sdk["ocr_sdk"]["pwd"]

    task_id = AbbySDK::OCR.start_process_image(app_id, pwd, lang, real_file_path)
    return task_id
  end

  def get_task_state(task_id)
    app_id = @ocr_sdk["ocr_sdk"]["app_id"]
    pwd =  @ocr_sdk["ocr_sdk"]["pwd"]

    AbbySDK::OCR.get_task_state(app_id, pwd, task_id)
  end


  def get_ocr_of_file(lang, file_path)
    real_file_path = get_real_file_path(lang, file_path)

    app_id = @ocr_sdk["ocr_sdk"]["app_id"]
    pwd =  @ocr_sdk["ocr_sdk"]["pwd"]

    result = AbbySDK::OCR.process_image(app_id, pwd, lang, real_file_path)
    return result
  end

end
