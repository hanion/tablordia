extends RichTextLabel


func _on_credit_meta_clicked(meta):
	var __er = OS.shell_open(str(meta))
