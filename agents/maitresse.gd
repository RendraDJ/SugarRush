extends CharacterBody2D

enum State { ECRITURE, SURVEILLANCE }
var current_state = State.ECRITURE

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D  # Référence au node AnimatedSprite2D

func _ready():
	changer_etat()

func changer_etat():
	if current_state == State.ECRITURE:
		print("La maîtresse écrit...")
		jouer_animation_ecriture()  # Jouer l'animation d'écriture
		await get_tree().create_timer(3).timeout  # Écriture pendant 3 secondes
		current_state = State.SURVEILLANCE
	else:
		print("La maîtresse surveille !")
		jouer_animation_surveillance()  # Jouer l'animation de surveillance
		await get_tree().create_timer(2).timeout  # Surveillance pendant 2 secondes
		current_state = State.ECRITURE
	changer_etat()  # Alterner les états

func surveille():
	return current_state == State.SURVEILLANCE

# Jouer l'animation de retour au tableau quand elle écrit
func jouer_animation_ecriture():
	if animated_sprite_2d != null:
		animated_sprite_2d.play("back_idle")  # Animation pour le retour au tableau

# Jouer l'animation de retour à la classe quand elle surveille
func jouer_animation_surveillance():
	if animated_sprite_2d != null:
		animated_sprite_2d.play("front_idle")  # Animation pour surveiller la classe
