extends CharacterBody2D

signal bonbon_recupere(eleve, bonbon)

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D  # Référence à AnimatedSprite2D

var position_initiale : Vector2
var cible = null  # Cible actuelle (bonbon)
var vitesse = 100  # Vitesse de déplacement

func _ready():
	position_initiale = position
	if animated_sprite_2d == null:
		print("Erreur : AnimatedSprite2D non trouvé !")  # Affiche un message d'erreur si le node n'existe pas

# Déplacement vers la cible (bonbon)
func aller_vers_cible():
	if cible:  # Vérifie que la cible existe
		# Vérification que la cible est toujours valide avant d'accéder à sa position
		if !is_instance_valid(cible):  # Assure que la cible existe encore dans la scène
			print("La cible n'est plus valide. Réinitialisation de la cible.")
			cible = null
			return
		
		var direction = (cible.position - position).normalized()
		velocity = direction * vitesse
		move_and_slide()

		# Vérifier si l'élève a atteint la cible
		if position.distance_to(cible.position) < 10:
			print("Bonbon récupéré par :", self.name)  # Log quand un bonbon est récupéré
			emit_signal("bonbon_recupere", self, cible)  # Émettre le signal
			# Supprimer le bonbon récupéré
			cible.queue_free()
			# Informer le game_manager de respawn un bonbon
			get_parent().respawn_bonbon()  # Appeler la fonction dans le game_manager pour respawn le bonbon
			cible = null

		# Vérifier si l'élève est en mouvement ou arrêté pour jouer l'animation
		if velocity.length() > 0:
			jouer_animation_deplacement(direction)
		else:
			jouer_animation_idle()

		# Assurer que l'élève ne sort pas du rectangle
		position.x = clamp(position.x, -177.145, 176.817)  # Limite horizontale
		position.y = clamp(position.y, 12, 103.471)  # Limite verticale
	else:
		print("Aucune cible définie pour", self.name)

# Retourner à la position initiale
func retour_position_initiale():
	var direction = (position_initiale - position).normalized()
	velocity = direction * vitesse
	move_and_slide()

	# Vérifier si l'élève retourne à sa position et jouer l'animation d'arrêt
	if velocity.length() > 0:
		jouer_animation_deplacement(direction)
	else:
		jouer_animation_idle()

# Définir une nouvelle cible (bonbon)
func set_cible(nouvelle_cible):
	cible = nouvelle_cible

# Jouer l'animation en fonction de la direction de déplacement
func jouer_animation_deplacement(direction: Vector2):
	if animated_sprite_2d != null:  # Vérifie si l'animation_player n'est pas null
		if abs(direction.x) > abs(direction.y):
			# Si l'élève se déplace horizontalement
			if direction.x > 0:
				animated_sprite_2d.play("right_walk")  # Animation de marche à droite
			else:
				animated_sprite_2d.play("left_walk")  # Animation de marche à gauche
		else:
			# Si l'élève se déplace verticalement
			if direction.y > 0:
				animated_sprite_2d.play("front_walk")  # Animation de marche vers l'arrière
			else:
				animated_sprite_2d.play("back_walk")  # Animation de marche vers l'avant

# Jouer l'animation d'inactivité en fonction de la direction
func jouer_animation_idle():
	if animated_sprite_2d != null:  # Vérifie si l'animation_player n'est pas null
		if velocity.x > 0:
			animated_sprite_2d.play("right_idle")  # Animation d'inactivité à droite
		elif velocity.x < 0:
			animated_sprite_2d.play("left_idle")  # Animation d'inactivité à gauche
		elif velocity.y > 0:
			animated_sprite_2d.play("back_idle")  # Animation d'inactivité vers l'arrière
		elif velocity.y < 0:
			animated_sprite_2d.play("front_idle")  # Animation d'inactivité vers l'avant
