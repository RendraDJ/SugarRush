extends Node

@export var eleves : Array[CharacterBody2D] = []
@export var prof : CharacterBody2D
@export var bonbon_scene : PackedScene
@export var nombre_de_bonbons : int = 5
@export var zone_spawn_min : Vector2 = Vector2(-177.145, 12)  # Limite du rectangle
@export var zone_spawn_max : Vector2 = Vector2(176.817, 103.471)  # Limite du rectangle

var bonbons : Array = []  # Liste de bonbons générés
var bonbons_deplaces : bool = false  # Indicateur pour savoir si les bonbons ont déjà été déplacés

# Nouveau timer
var temps_restant : float = 60.0  # 60 secondes pour la partie
var partie_terminee : bool = false  # Booléen pour savoir si la partie est finie
var scores : Dictionary = {}  # Dictionnaire pour stocker les scores des élèves

@onready var timer_label : Label = $TimerLabel  # Référence vers le Label du Timer

func _ready():
	initialiser_scores()
	generer_bonbons()
	print("Le jeu commence !")

	# Initialiser le texte du timer
	timer_label.text = "Temps restant: 60s"

	# Connecter les signaux des élèves pour suivre la récupération des bonbons
	for eleve in eleves:
		eleve.connect("bonbon_recupere", _on_bonbon_recupere.bind(eleve))

# Fonction pour initialiser les scores des élèves
func initialiser_scores():
	for eleve in eleves:
		scores[eleve.name] = 0  # Chaque élève commence avec un score de 0

# Gestion du timer dans le _process
func _process(delta):
	if partie_terminee:
		return  # Si la partie est finie, arrêter le _process

	# Réduire le temps restant
	temps_restant -= delta
	if temps_restant <= 0:
		temps_restant = 0
		fin_de_partie()
		return

	# Mettre à jour le texte du timer visuellement
	timer_label.text = "Temps restant: " + str(ceil(temps_restant)) + "s"

	# Gestion des élèves pendant le jeu
	for eleve in eleves:
		if prof.surveille():
			eleve.retour_position_initiale()
		else:
			# Trouver le bonbon le plus proche pour chaque élève
			var bonbon_proche = trouver_bonbon_le_plus_proche(eleve)
			if bonbon_proche:
				eleve.set_cible(bonbon_proche)  # Assigner la cible (bonbon)
				eleve.aller_vers_cible()

	# Déplacer les bonbons si la maîtresse surveille
	deplacer_bonbons_si_surveille()

# Générer les bonbons dans la zone aléatoire
func generer_bonbons():
	for i in range(nombre_de_bonbons):
		var bonbon = bonbon_scene.instantiate()
		bonbon.position = obtenir_position_aleatoire()
		add_child(bonbon)
		print("Bonbon généré à :", bonbon.position)
		bonbons.append(bonbon)

# Obtenir une position aléatoire dans le rectangle
func obtenir_position_aleatoire():
	var x = randf_range(zone_spawn_min.x, zone_spawn_max.x)
	var y = randf_range(zone_spawn_min.y, zone_spawn_max.y)
	return Vector2(x, y)

# Déplacer les bonbons si la prof surveille
func deplacer_bonbons_si_surveille():
	if prof.surveille() and !bonbons_deplaces:
		for bonbon in bonbons:
			if is_instance_valid(bonbon):
				bonbon.position = obtenir_position_aleatoire()
				print("Bonbon déplacé à :", bonbon.position)
		bonbons_deplaces = true

# Trouver le bonbon le plus proche d'un élève
func trouver_bonbon_le_plus_proche(eleve: CharacterBody2D) -> Node:
	var bonbon_proche = null
	var distance_min = INF

	for bonbon in bonbons:
		if is_instance_valid(bonbon):
			var distance = eleve.position.distance_to(bonbon.position)
			if distance < distance_min:
				distance_min = distance
				bonbon_proche = bonbon

	return bonbon_proche

# Fonction appelée quand un bonbon est récupéré
func _on_bonbon_recupere(eleve, bonbon):
	if partie_terminee:
		return  # Ne rien faire si la partie est finie

	print("Bonbon récupéré par :", eleve.name)
	scores[eleve.name] += 1  # Incrémenter le score de l'élève

	# Afficher le score actuel de l'élève
	print("Score actuel de", eleve.name, ":", scores[eleve.name])

	# Supprimer le bonbon de la liste et de la scène
	bonbons.erase(bonbon)
	bonbon.queue_free()

	# Respawn un nouveau bonbon
	respawn_bonbon()

# Respawn un bonbon
func respawn_bonbon():
	var bonbon = bonbon_scene.instantiate()
	bonbon.position = obtenir_position_aleatoire()
	add_child(bonbon)
	bonbons.append(bonbon)
	print("Bonbon respawné à :", bonbon.position)

# Fonction pour terminer la partie
func fin_de_partie():
	partie_terminee = true
	timer_label.text = "Temps écoulé !"  # Mettre à jour le texte final
	print("La partie est terminée !")

	# Trouver l'élève gagnant
	var gagnant = trouver_gagnant()
	if gagnant:
		print("L'élève gagnant est :", gagnant, "avec", scores[gagnant], "bonbons collectés !")
	else:
		print("Égalité entre les élèves !")

# Trouver l'élève avec le score le plus élevé
func trouver_gagnant():
	var max_score = -1
	var gagnant = null

	for eleve_name in scores.keys():
		if scores[eleve_name] > max_score:
			max_score = scores[eleve_name]
			gagnant = eleve_name
		elif scores[eleve_name] == max_score:
			gagnant = null  # En cas d'égalité, aucun gagnant n'est désigné

	return gagnant
