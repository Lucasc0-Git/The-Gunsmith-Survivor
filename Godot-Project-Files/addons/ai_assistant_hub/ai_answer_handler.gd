@tool
class_name AIAnswerHandler

signal bot_message_produced(message:String)
signal error_message_produced(message:String)

const COMMENT_LENGTH := 80

var _code_writer: AssistantToolCodeWriter


func _init(plugin:EditorPlugin, code_selector:AssistantToolSelection) -> void:
	_code_writer = AssistantToolCodeWriter.new(plugin, code_selector)


func handle(text_answer:String, quick_prompt:AIQuickPromptResource) -> void:
	#Simple chat
	if quick_prompt == null:
		bot_message_produced.emit(text_answer)
	#Response is for a quick prompt
	else:
		if quick_prompt.format_response_as_comment:
			text_answer = _convert_to_comment(text_answer)
		bot_message_produced.emit(text_answer)
		match quick_prompt.response_target:
			AIQuickPromptResource.ResponseTarget.CodeEditor:
				_write_to_code_editor(text_answer, quick_prompt.code_placement)
			AIQuickPromptResource.ResponseTarget.OnlyCodeToCodeEditor:
				var code = _extract_gdscript(text_answer)
				if code.length() > 0:
					_write_to_code_editor(code, quick_prompt.code_placement)


func _write_to_code_editor(text_answer:String, code_placement:AIQuickPromptResource.CodePlacement) -> void:
	var succeed = _code_writer.write_to_code_editor(text_answer, code_placement)
	if not succeed:
		error_message_produced.emit("The selection sent to the assistant was not found, you need to make the changes manually based on the response in the chat.")


func _extract_gdscript(text:String) -> String:
	var extracted_code:= ""
	var start:= text.find("```gdscript")
	var end:= text.find("```", start + 11)
	while start >= 0 and end >= start:
		if extracted_code.length() > 0:
			extracted_code += "\n"
		extracted_code += text.substr(start+11, end-start-11)
		start = text.find("```gdscript", end+3)
		end = text.find("```", start + 11)
	return extracted_code


func _convert_to_comment(text:String) -> String:
	text = text.strip_edges(true, true)
	if text.begins_with("#"):
		#trusting the model returned a comment somewhat formatted
		return text
	else:
		#formatting the comment
		var result := "# "
		var line_length := COMMENT_LENGTH
		var curr_line_length := 0
		for i in range(text.length()):
			if curr_line_length >= line_length and text[i] == " ":
				result += "\n# "
				curr_line_length = 0
			else:
				result += text[i]
				if text[i] == "\n":
					result += "# "
					curr_line_length = 0
				curr_line_length += 1
		return result
