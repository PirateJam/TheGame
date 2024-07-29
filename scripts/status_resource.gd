extends Resource
class_name StatusResource

@export var name: String
@export var duration: float
@export var effect_function: String  # Name of the function to call for this effect
@export var args: Array = []  # Arguments to pass to the func
@export var tick_interval: float = 1.0  # Interval in seconds for the effect to tick
