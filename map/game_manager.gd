extends Node

@export var eleves : Array[CharacterBody2D] = []
@export var prof : CharacterBody2D
@export var bonbon_scene : PackedScene
@export var nombre_de_bonbons : int = 5
@export var zone_spawn_min : Vector2 = Vector2(-177.145, 12)  # Limite du rectangle
@export var zone_spawn_max : Vector2 = Vector2(176.817, 103.471)  # Limite du rectangle

var bonbons : Array = []  # Liste de bonbons générés
var bonbons_deplaces : bool = false  # Indicateur pour savoir si les bonbons ont déjà été déplacés

func _ready():
	generer_bonbons()
	print("Le jeu commence !")

# Générer les bonbons dans le rectangle
func generer_bonbons():
	for i in range(nombre_de_bonbons):
		var bonbon = bonbon_scene.instantiate()
		bonbon.position = obtenir_position_aleatoire()  # Position aléatoire dans la zone
		add_child(bonbon)
		print("Bonbon généré à :", bonbon.position)
		bonbons.append(bonbon)  # Ajouter le bonbon à la liste

# Obtenir une position aléatoire dans le rectangle
func obtenir_position_aleatoire():
	var x = randf_range(zone_spawn_min.x, zone_spawn_max.x)
	var y = randf_range(zone_spawn_min.y, zone_spawn_max.y)
	return Vector2(x, y)

# Déplacer les bonbons une seule fois si la prof surveille
func deplacer_bonbons_si_surveille():
	if prof.surveille() and !bonbons_deplaces:
		for bonbon in bonbons:
			if is_instance_valid(bonbon):  # Vérifier que le bonbon est valide
				bonbon.position = obtenir_position_aleatoire()  # Déplacer le bonbon à une nouvelle position aléatoire
				print("Bonbon déplacé à :", bonbon.position)
		bonbons_deplaces = true  # Marquer que les bonbons ont été déplacés

# Fonction pour trouver le bonbon le plus proche d'un élève
func trouver_bonbon_le_plus_proche(eleve: CharacterBody2D) -> Node:
	var bonbon_proche = null
	var distance_min = INF  # Initialise une distance infinie

	for bonbon in bonbons:
		# Vérifier si le bonbon est toujours valide avant d'accéder à sa position
		if is_instance_valid(bonbon):
			var distance = eleve.position.distance_to(bonbon.position)
			if distance < distance_min:
				distance_min = distance
				bonbon_proche = bonbon

	return bonbon_proche

# Mise à jour dans le _process pour gérer le déplacement des élèves
func _process(delta):
	for eleve in eleves:
		if prof.surveille():
			eleve.retour_position_initiale()
		else:
			# Trouver le bonbon le plus proche pour chaque élève
			var bonbon_proche = trouver_bonbon_le_plus_proche(eleve)
			if bonbon_proche:
				eleve.set_cible(bonbon_proche)  # Assigner la cible (bonbon)
				eleve.aller_vers_cible()  # Déplacer l'élève vers la cible
			else:
				print("Aucun bonbon disponible pour", eleve.name)
	
	# Déplacer les bonbons une seule fois si la prof est en mode surveillance
	deplacer_bonbons_si_surveille()

# Méthode de gestion du signal bonbon récupéré
func _on_bonbon_recupere(eleve, bonbon):
	print("Bonbon récupéré par :", eleve.name)
	# Supprimer le bonbon récupéré de la liste des bonbons
	bonbons.erase(bonbon)
	bonbon.queue_free()  # Supprimer le bonbon récupéré
	respawn_bonbon()  # Respawn du bonbon

# Fonction pour respawn un bonbon
func respawn_bonbon():
	# Créer et positionner un nouveau bonbon à une position aléatoire
	var bonbon = bonbon_scene.instantiate()
	bonbon.position = obtenir_position_aleatoire()
	print("Bonbon respawné à :", bonbon.position)
	add_child(bonbon)
	bonbons.append(bonbon)
