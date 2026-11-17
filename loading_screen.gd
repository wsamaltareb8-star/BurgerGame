extends Control

# اسحب مشهد الكشك الرئيسي (main.tscn) من FileSystem وضعه هنا في Inspector
@export var target_scene: PackedScene
# أو اكتب مساره هنا كخيار احتياطي
@export_file("*.tscn") var fallback_scene_path: String = "res://main.tscn"
# مدة بقاء شاشة التحميل لقراءة التعليمات (بالثواني)
@export var display_duration: float = 3.5

@onready var progress_bar: ProgressBar = find_child("LoadingBar", true, false)

var elapsed_time: float = 0.0
var is_switching: bool = false

func _ready() -> void:
	if progress_bar:
		progress_bar.min_value = 0.0
		progress_bar.max_value = 100.0
		progress_bar.value = 0.0

func _process(delta: float) -> void:
	if is_switching:
		return
		
	elapsed_time += delta
	var percent = clamp((elapsed_time / display_duration) * 100.0, 0.0, 100.0)
	
	if progress_bar:
		progress_bar.value = percent
		
	# الانتقال المضمون فور وصول الشريط إلى 100%
	if elapsed_time >= display_duration:
		is_switching = true
		go_to_game()

func go_to_game() -> void:
	if target_scene != null:
		get_tree().change_scene_to_packed(target_scene)
	elif ResourceLoader.exists(fallback_scene_path):
		get_tree().change_scene_to_file(fallback_scene_path)
	else:
		print("خطأ: لم يتم العثور على مشهد الكشك! اسحب المشهد إلى خانة Target Scene في Inspector.")
