window.onload = (()->
  # Keyboard constructor
  RUN_TESTS = false
  Keyboard = ()->

  	scene = new THREE.Scene()
  	camera = new THREE.PerspectiveCamera(73, window.innerWidth / window.innerHeight, 0.1, 1000)

  	renderer = new THREE.WebGLRenderer({antialias: true})
  	canvas =
  		height: window.innerHeight / 2
  		width: window.innerWidth * 0.95
  	renderer.setSize(canvas.width, canvas.height)

  	screen = document.getElementById('keyboard').appendChild( renderer.domElement )

  	MIDI.setVolume(0, 127)

  	q_song = document.getElementById("questionable")
  	b_song = document.getElementById("bead")
  	c_song = document.getElementById("ceg")
  	fail_song = document.getElementById("the_fail_song")

  	# Camera
  	add_camera = ()->
  		camera.position.x = 0
  		camera.position.y = -60
  		camera.position.z = 125
  		camera.lookAt(new THREE.Vector3(0,5,0))

  	# Lights
  	spot_light = null
  	add_lights = ()->
  		ambient_light = new THREE.AmbientLight(0x808080)
  		scene.add(ambient_light)

  		directional_light = new THREE.DirectionalLight(0x404040, 0.6)
  		directional_light.position.set(0, 400, -60)
  		scene.add(directional_light)

  		point_light = new THREE.PointLight(0xffffff, 0.45, 1000)
  		point_light.position.set(-45,15,80)
  		scene.add(point_light)

  		spot_light = new THREE.SpotLight({color: 0xffffff, intensity: 0.95})
  		spot_light.position.set(0, 400, 500)
  		spot_light.target.position.set(0,-50, -50)
  		spot_light.exponent = 10.0
  		scene.add(spot_light)

  	# Background
  	add_background = ()->
  		background = new THREE.Mesh(new THREE.PlaneGeometry(5000, 5000), new THREE.MeshBasicMaterial({color: 0x000000}))
  		background.position.z = -500
  		scene.add(background)

  	# Keyboard
  	nextWhiteKey = (key)->
  		return "D" if key is "C"
  		return "E" if key is "D"
  		return "F" if key is "E"
  		return "G" if key is "F"
  		return "A" if key is "G"
  		return "B" if key is "A"
  		return "C" if key is "B"

  	if RUN_TESTS
	  	test('nextWhiteKey(key) - Returns the next white key', ()->
  			keys = ["C","D","E","F","G","A","B","C"]
  			for key, index in keys
  				if index != (keys.length - 1)
  					equal(nextWhiteKey(key), keys[index+1], keys[index+1] + ' follows ' + key))

	  spacingToNextWhiteKey = (key, gap_length)->
  		delta = getDelta(key)

  		if key is "C" or key is "F"
    		return (delta/2 + (24 - delta)) + gap_length + keyCenter(nextWhiteKey(key))
  		else if key is "B" or key is "E"
    		return (24 - delta)/2 + gap_length + keyCenter(nextWhiteKey(key))
  		else if key is "D" or key is "A"
    		return (24 - delta[0] - delta[1])/2 + delta[1] + gap_length + keyCenter(nextWhiteKey(key))
  		else # key is G
  			return (24 - delta[0] - delta[1])/2 + delta[1] + gap_length + keyCenter(nextWhiteKey(key))

  	spacingToNextBlackKey = (key, gap_length, blk_key_width)->
    	if key is "B" or key is "E"
    		return 0
    	delta = getDelta(key)

    	if key is "C" or key is "F"
    		return delta/2 + gap_length/2 + blk_key_width/2
    	else
    		return (24 - delta[0] - delta[1])/2 + gap_length/2 + blk_key_width/2

    constant =
    	white_key_height: 100
    	white_key_width: 24
    	black_key_height: 60
    	black_key_width: 14
    	key_spacing: 1.1
    	key_offset: -73

    key_played = ''
    highlighted_key = ''

    material =
    	ivory: 0
    	black: 0
    	key_pressed: 0
    	cabinet: 0
    	banner: 0
    	pointer: 0

    objects =
    	white_key: []
    	black_key: []

  	note_labels =
  		white: []
  		black: []

  	layout =
  		white_keys: ["F","G","A","B","C","D","E","F","G","A","B","C","D","E","F","G","A","B"]
  		black_keys: ["F#/Gb","G#/Ab","A#/Bb","C#/Db","D#/Eb"]

  	chords = [["C","E","G"], ["D","F#/Gb","A"], ["E","G#/Ab","B"], ["F","A","C"], ["G","B","D"], ["A","C#/Db","E"], ["B","D#/Eb","F#/Gb"], \
  		["C#/Db","F","G#/Ab"], ["D#/Eb","G","A#/Bb"], ["F#/Gb","A#/Bb","C#/Db"], ["G#/Ab","C","D#/Eb"], ["A#/Bb","D","F"]]

  	practice_keys = []
  	current_triad_name = null
  	major_triad_names =
  		white: []
  		black: []

  	root_selected = null
  	current_scale_degree = null
  	current_scale = []
  	scale_degree_names = []

  	current_pointer = null
  	pointers = []

  	event = 0

  	create_materials = ()->
  		material.ivory = new THREE.MeshPhongMaterial({color: 0xfaf7c4, side: THREE.DoubleSide})
  		material.ivory.ambient.copy(material.ivory.color)

  		material.banner = new THREE.MeshPhongMaterial({emissive: 0x000000, side: THREE.DoubleSide})
  		material.banner.ambient.copy(material.banner.color)

  		specular_color = new THREE.Color()
  		specular_color.setRGB(0.95, 0.95, 0.95)
  		material.black = new THREE.MeshPhongMaterial({color: 0x000000, side: THREE.DoubleSide, shininess: 30, specular: specular_color})
  		material.black.ambient.copy(material.black.color)

  		cab_specular = new THREE.Color()
  		cab_specular.setRGB(0.9, 0.9, 0.9)

  		material.cabinet = new THREE.MeshPhongMaterial({shininess: 70, color: 0x996633, map: THREE.ImageUtils.loadTexture("textures/wood.jpg"), specular: cab_specular})
  		material.cabinet.ambient.copy(material.cabinet.color)

  		material.key_pressed = new THREE.MeshFaceMaterial([ new THREE.MeshLambertMaterial({emissive: 0x0000ff, color: 0xff0000, side: THREE.DoubleSide, shininess: 40})])

  		material.pointer = new THREE.MeshPhongMaterial({shininess: 100, side: THREE.DoubleSide, color: 0x007ade})
  		material.pointer.ambient.copy(material.pointer.color)

  	add_keys = (keyboard)->
  		white_key_position = 0
  		b_index = 0
  		white_key_geometry = 0
  		for key, index in layout.white_keys
  			if key in "CF"
  				white_key_geometry = geometryOfCF(key, constant.white_key_height, constant.black_key_height, constant.black_key_width)
  			else if key in "BE"
  				white_key_geometry = geometryOfBE(key, constant.white_key_height, constant.black_key_height, constant.black_key_width)
  			else
  				white_key_geometry = geometryOfDGA(key, constant.white_key_height, constant.black_key_height, constant.black_key_width)

  			objects.white_key[index] = new THREE.Mesh(white_key_geometry, material.ivory)
  			objects.white_key[index].id = 'white ' + index
  			objects.white_key[index].name = layout.white_keys[index]

  			objects.white_key[index].position.x = white_key_position + constant.key_offset

  			objects.white_key[index].scale.x = 1
  			objects.white_key[index].scale.z = 1.75

  			keyboard.add(objects.white_key[index])

  			black_key_position = spacingToNextBlackKey(key, constant.key_spacing, constant.black_key_width)/3
  			if black_key_position > 0
  				black_key_geometry = blackKeyGeometry(constant.black_key_height, constant.black_key_width)

  				objects.black_key[b_index] = new THREE.Mesh(black_key_geometry, material.black)
  				objects.black_key[b_index].id = 'black ' + b_index
  				objects.black_key[b_index].name = layout.black_keys[convertKeyIndex('black', b_index)]

  				objects.black_key[b_index].position.x = objects.white_key[index].position.x + black_key_position
  				objects.black_key[b_index].position.y = -constant.black_key_height/2/3
  				objects.black_key[b_index].position.z = 1

  				S = 1
  				objects.black_key[b_index].scale.x = 1
  				objects.black_key[b_index].scale.y = S
  				objects.black_key[b_index].scale.z = 1.55

  				keyboard.add(objects.black_key[b_index])
  				b_index = b_index + 1

  			white_key_position = white_key_position + spacingToNextWhiteKey(key, constant.key_spacing)/3

  	add_cabinet = (keyboard)->
  		cabinet = new THREE.Object3D()
  		cabinet_height = 200
  		cabinet_width = 60

  		cabinet_bottom_geometry = new THREE.BeveledBlockGeometry(cabinet_height, cabinet_width, constant.black_key_height * 0.15, 0.5)
  		cabinet_bottom = new THREE.Mesh(cabinet_bottom_geometry, material.cabinet)
  		cabinet_bottom.translateY(-12)
  		cabinet.add(cabinet_bottom)

  		cabinet_back = new THREE.Object3D()
  		cabinet_back_geometry = new THREE.BeveledBlockGeometry(cabinet_height, cabinet_width/0.9, constant.black_key_height * 0.15, 0.5)
  		cabinet_back = new THREE.Mesh(cabinet_back_geometry, material.cabinet)

  		brand_name = new THREE.Object3D()
  		brand_name_geometry = new THREE.TextGeometry("Mineway", {
  			size: 16,
  			height: 10;
  			curveSegments: 20;
  			font: "optimer",
  			weight: "bold",
  			style: "normal",
  			bevelThickness: 0.5,
  			bevelSize: 0.3,
  			bevelEnabled: true,
  			material: 0,
  			extrudeMaterial: 1})

  		brand_name = new THREE.Mesh(brand_name_geometry, material.cabinet)
  		brand_name.translateX(-38)
  		brand_name.translateY(7)
  		cabinet_back.add(brand_name)

  		cabinet_back.translateY(10)
  		cabinet_back.translateZ(15)
  		cabinet_back.rotation.x = Math.PI/3.7
  		cabinet.add(cabinet_back)

  		cabinet.translateZ(-4)
  		cabinet.id = 'cabinet'
  		keyboard.add(cabinet)

  	add_keyboard = ()->
	  	keyboard = new THREE.Object3D()
	  	keyboard.id = 'keyboard'
	  	scene.add(keyboard)

  		black_MIDI_keys_in_first_octave = [54,56,58,61,63]
  		white_MIDI_keys_in_first_octave = []
  		white_MIDI_keys_in_first_octave.push x for x in [53..64] when x not in black_MIDI_keys_in_first_octave

  		add_keys(keyboard)
  		add_cabinet(keyboard)

  		position = (keyboard)->
  			keyboard.rotation.x = -Math.PI/6.5
  			keyboard.translateZ(0)
  			keyboard.translateY(-12)

  		position(keyboard)
  		create_pointer(keyboard)

  	# Key label
  	create_pointer = (keyboard)->
	  	pointer = new THREE.Object3D()
  		pointer.id = 'pointer'

  		pointer_body = new THREE.Mesh(new THREE.CylinderGeometry(3, 3, 15, 10, 10, false), material.pointer)
  		pointer_body.id = 'body'
  		pointer.add(pointer_body)

  		pointer_head = new THREE.Mesh(new THREE.CylinderGeometry(0, 5, 17, 10, 10, false), material.pointer)
  		pointer_head.rotation.x = Math.PI
  		pointer_head.position.y = -(15/2 + 7/2)
  		pointer_head.id = 'head'
  		pointer.add(pointer_head)

  		keyboard.add(pointer)

  	create_pointer_labels = ()->
  		[note_labels.white, major_triad_names.white] = createNoteLabels(layout.white_keys[0..6], note_labels.white, major_triad_names.white, 5)
  		[note_labels.black, major_triad_names.black] = createNoteLabels(layout.black_keys, note_labels.black, major_triad_names.black, 20)

  	initialize_pointers = (color, notes, labels)->
  		for note, index in notes
  			pointers[index] = new THREE.Object3D()
  			pointers[index].id = note
  			pointers[index].name = 'pointer'

  			pointer_body = new THREE.Mesh(new THREE.CylinderGeometry(3, 3, 15, 10, 10, false), material.pointer)
  			pointer_body.id = 'body'
  			pointers[index].add(pointer_body)

  			pointer_head = new THREE.Mesh(new THREE.CylinderGeometry(0, 5, 17, 10, 10, false), material.pointer)
  			pointer_head.rotation.x = Math.PI
  			pointer_head.position.y = -(15/2 + 7/2)
  			pointer_head.id = 'head'
  			pointers[index].add(pointer_head)

  			pointers[index].add(labels[convertKeyIndex(color, index)])

  	create_pointers = ()->
  		create_pointer_labels()
  		initialize_pointers('white', layout.white_keys, note_labels.white)
  		initialize_pointers('black', layout.black_keys, note_labels.black)

  	createScene = ()->
  		create_materials()
  		create_pointers()
  		scale_degree_names = createScaleDegrees(scale_degree_names)
  		add_camera()
  		add_background()
  		add_lights()
  		add_keyboard()

  	# Key press labels and sound connection
  	MIDI_keys =
  		delay: 1/2
  		velocity: 127
  		black_in_first_octave: [54,56,58,61,63]
  		white_in_first_octave: []

  	MIDI_keys.white_in_first_octave.push x for x in [53..64] when x not in MIDI_keys.black_in_first_octave
  	MIDI.setVolume(0,127)

  	getMIDIkey = (key_color, key_index)->
  		if key_color is 'black'
  			k = Math.floor(key_index/5)
  			return MIDI_keys.black_in_first_octave[key_index - 5 * k] + 12 * k
  		else
  			k = Math.floor(key_index/7)
  			return MIDI_keys.white_in_first_octave[key_index - 7 * k] + 12 * k

  	if RUN_TESTS
  		test('getMIDIkey(key_color, key_index) - Returns the MIDI key number', ()->
  			equal(getMIDIkey('white', 0), 53, 'F3 key')
  			equal(getMIDIkey('black', 0), 54, 'F#3 key')
  			equal(getMIDIkey('white', 4), 60, 'C4 key - middle C')
  			equal(getMIDIkey('white', 9), 69, 'A#4 key')
  			equal(getMIDIkey('white', 17), 83, 'B5 key'))

  	convertKeyIndex = (key_color, key_index)->
  		base = 7
  		base = 5 if key_color is 'black'
  		k = Math.floor(key_index/base)
  		return (key_index - base * k)

  	if RUN_TESTS
  		test('convertKeyIndex(key_color, key_index) - Returns the position of a key given its color, base 7 for white keys, base 5 for black keys', ()->
  			equal(convertKeyIndex('white', 0), 0, 'The first white key F3 has white key index 0')
  			equal(convertKeyIndex('white', 8), 1, 'The eighth white key G4 has white key index 1')
  			equal(convertKeyIndex('black', 0), 0, 'The first black key F#3 has black key index 0')
  			equal(convertKeyIndex('black', 5), 0, 'The fifth black key has black key index 0')
  			equal(convertKeyIndex('black', 2), 2, 'The third black key C#4 has black key index 2')
  			equal(convertKeyIndex('black', 7), 2, 'The eighth black key A#4 has black key index 2'))

  	createNoteLabels = (notes, buffer, majorBuffer, offset)->
  		black = true if "#" in notes[0]
  		i = 0
  		for note in notes
  			label_geometry = new THREE.TextGeometry(note, {
  				size: 14,
  				height: 3,
  				curveSegments: 30,
  				font: 'optimer',
  				weight: 'normal',
  				style: 'normal',
  				bevelThickness: 0.5,
  				bevelSize: 0.3,
  				bevelEnabled: true,
  				material: 0,
  				extrudeMaterial: 1})
  			buffer[i] = new THREE.Mesh(label_geometry, material.pointer)
  			buffer[i].position.x -= offset
  			buffer[i].position.y += 12
  			buffer[i].rotation.x = -20 * Math.PI/180
  			buffer[i].id = note

  			label_geometry = new THREE.TextGeometry(note + " Major Triad", {
  				size: 18,
  				height: 8,
  				curveSegments: 30,
  				font: 'optimer',
  				weight: 'normal',
  				style: 'normal',
  				bevelThickness: 0.5,
  				bevelSize: 0.3,
  				bevelEnabled: true,
  				material: 0,
  				extrudeMaterial: 1})
  			majorBuffer[i] = new THREE.Mesh(label_geometry, material.pointer)
  			majorBuffer[i].id = note
  			majorBuffer[i].scale.x = 1.0
  			majorBuffer[i].scale.y = 1.0
  			majorBuffer[i].translateX(-60)
  			majorBuffer[i].translateX(-30) if black
  			majorBuffer[i].translateY(90)
  			majorBuffer[i].rotation.x = 45 * Math.PI/180

  			i += 1
  		return [buffer, majorBuffer]

  	createScaleDegrees = (buffer)->
	  	scale = [[2,"2nd"],[3,"3rd"],[4,"4th"],[5,"5th"],[6,"6th"],[7,"7th"],[2,"9th"],[4,"11th"],[6,"13th"]]

  		i = 0
  		for degree in scale
  			label_geometry = new THREE.TextGeometry(degree[1] + " note", {
  				size: 18,
  				height: 8,
  				curveSegments: 30,
  				font: 'optimer',
  				weight: 'normal',
  				style: 'normal',
  				bevelThickness: 0.5,
  				bevelSize: 0.3,
  				bevelEnabled: true,
  				material: 0,
  				extrudeMaterial: 1})
  			buffer[i] = new THREE.Mesh(label_geometry, material.pointer)
  			buffer[i].id = degree[0]
  			buffer[i].name = degree[1]
  			buffer[i].scale.x = 1.0
  			buffer[i].scale.y = 1.0
  			buffer[i].translateY(90)
  			buffer[i].translateX(-40)
  			buffer[i].rotation.x = 45 * Math.PI/180
  			i += 1

  		return buffer

  	getNoteLabel = (key_color, key_index)->
  		index = convertKeyIndex(key_color, key_index)
  		if key_color is 'black'
  			return note_labels.black[index]
  		else
  			return note_labels.white[index]

  	chromatic_scale = ["A","A#/Bb","B","C","C#/Db","D","D#/Eb","E","F","F#/Gb","G","G#/Ab"]
  	getWholeStep = (note)->
  		if note in ["G","G#/Ab"]
  			return "A" if note is "G"
  			return "A#/Bb"
  		return chromatic_scale[index+2] for scale_note, index in chromatic_scale when note is scale_note

  	getHalfStep = (note)->
  		if note is "G#/Ab"
  			return "A"
  		return chromatic_scale[index+1] for scale_note, index in chromatic_scale when note is scale_note

  	getNextNote = (note, step)->
  		return getWholeStep(note) if step is 'whole_step'
  		return getHalfStep(note) if step is 'half_step'

  	parseKeyObject = (key_played)->
  		key_info = key_played.split(' ')
  		key_color = key_info[0]
  		key_index = parseInt(key_info[1])
  		return [key_color, key_index]

  	playScale = (key_color, key_index)->
  		current_scale.push(current_scale[0])

  		midi_start = getMIDIkey(key_color, key_index)

  		if key_color is 'white'
  			midi_start = midi_start - 7 if midi_start > 71
  		else
  			midi_start = midi_start - 7 if midi_start > 70

  		delay = 0.5
  		for half_step_offset, index in [0,2,4,5,7,9,11,12]
  			playNote(midi_start + half_step_offset, index/16 + delay)

  	pressKey = (key_played, play_note)->
  		return if key_played is ''

  		[key_color, key_index] = parseKeyObject(key_played)

  		if key_color is 'white'
  			objects.white_key[key_index].material = material.pointer
  			objects.white_key[key_index].rotation.x = Math.PI/20
  			showPointer(objects.white_key[key_index], key_color, key_index)
  		else
  			objects.black_key[key_index].material = material.pointer
  			objects.black_key[key_index].rotation.x = Math.PI/10
  			showPointer(objects.black_key[key_index], key_color, key_index)

  		if play_note
	  		playNote(getMIDIkey(key_color, key_index), 0)

  	releaseKey = ()->
  		return if key_played is ''
  		hidePointer()
  		[key_color, key_index] = parseKeyObject(key_played)

  		if key_color is 'white'
  			objects.white_key[key_index].material = material.ivory
  			objects.white_key[key_index].rotation.x = 0
  		else
  			objects.black_key[key_index].material = material.black
  			objects.black_key[key_index].rotation.x = 0

  		current_pointer = null

  	generateScale = (tonic)->
  	  [key_info, key_index] = parseKeyObject(tonic)
  	  releaseKey(tonic)

  	  note_name = object.name for object in objects.white_key when object.id is tonic
  	  if not note_name
  	  	note_name = object.name for object in objects.black_key when object.id is root

  	  notes_in_scale = [tonic]
  	  scale = []
  	  scale[0] = note_name

  	  for step, index in ['whole_step','whole_step','half_step','whole_step','whole_step','whole_step']
  	  	scale[index+1] = getNextNote(scale[index], step)
  	  return scale

	  showPointer = (key, key_color, key_index)->
	  	current_pointer = pointer for pointer in pointers when (pointer.id is getNoteLabel(key_color, key_index).id) and (pointer.name is 'pointer')

  		current_pointer.position.x = key.position.x
  		if key_color is 'black'
  			current_pointer.position.y = key.position.y
  			current_pointer.position.z = 30
  		else
  			current_pointer.position.y = key.position.y - constant.white_key_height/4.0
  			current_pointer.position.z = 20

  		current_pointer.rotation.x = 75 * Math.PI/180
  		current_pointer.scale.set(0.65, 0.65, 0.65)
  		getObject('keyboard').add(current_pointer)

  	hidePointer = ()->
  		getObject('keyboard').remove(current_pointer)
  		current_pointer = null

  	traceRayIntoScene = (x_coordinate, y_coordinate)->
  		element = renderer.domElement
  		bounding_rectangle = element.getBoundingClientRect()
  		screen =
  			x: (x_coordinate - bounding_rectangle.left) * (element.width/bounding_rectangle.width)
  			y: (y_coordinate - bounding_rectangle.top) * (element.height/bounding_rectangle.height)

  		vector = new THREE.Vector3((screen.x/canvas.width) * 2 - 1, -(screen.y/canvas.height) * 2 + 1, 0.5)

  		projector = new THREE.Projector()
  		projector.unprojectVector(vector, camera)
  		direction = vector.sub(camera.position).normalize()

  		return ray = new THREE.Raycaster(camera.position, direction)

  	getKeyPlayed = (event)->
  		intersections = []

  		ray = traceRayIntoScene(event.clientX, event.clientY)
  		intersections = ray.intersectObjects(objects.black_key)
  		intersections.push(x) for x in ray.intersectObjects(objects.white_key)

  		distances = (y.distance for y in intersections)
  		shortest_distance = Math.min.apply(null, distances)
  		closest_object = (x.object.id for x in intersections when x.distance == shortest_distance)

  		if closest_object.length > 0
	  		return closest_object[0]
	  	else
	  		return ''

  	randomlySelectNewName = (current_name)->
  		previous_name = current_name
  		if Math.random() < 0.5
  			while previous_name is current_name
	  			triad_choice = Math.floor(5.0 * Math.random())
  				current_name = major_triad_names.black[triad_choice]
  		else
  			while previous_name is current_name
	  			triad_choice = Math.floor(7.0 * Math.random())
  				current_name = major_triad_names.white[triad_choice]

  		return current_name

  	selectTriad = ()->
  		scene.remove(current_triad_name)
  		current_triad_name = randomlySelectNewName(current_triad_name)
  		scene.add(current_triad_name)

  	checkTriad = (practice_chord)->
  		[exists, name] = isValidMajorChord(practice_chord)
  		if exists
  			played_triad_name = null
  			played_triad_name = triad for triad in major_triad_names.white when triad.id is name[0]
  			if played_triad_name is null
  				played_triad_name = triad for triad in major_triad_names.black when triad.id is name[0]

  			if played_triad_name is current_triad_name
  				playChord(practice_chord, 0.75)
  				return true

  		playFail()
  		return false

  	isValidMajorChord = (practice_chord)->
  		chord_labels = []
  		chord_labels.push(getNoteLabel(note[0], note[1]).id) for note in practice_chord

  		return [true, chords[index]] for chord, index in chords when isSameChord(chord, chord_labels)
  		return [false, []]

  	isSameChord = (chord1, chord2)->
  		return false if chord1.length != chord2.length

  		result = true
  		for note in chord1
  			result = result and (note in chord2)
  		return result

  	selectScaleDegree = ()->
  		scene.remove(current_scale_degree)
  		previous_degree = current_scale_degree

  		while previous_degree is current_scale_degree
  			degree_choice = Math.floor(Math.random() * 9)
	  		current_scale_degree = scale_degree_names[degree_choice]

  		scene.add(current_scale_degree)

  	checkScaleDegree = (key_played)->
  		[key_color, key_index] = parseKeyObject(key_played)

  		key_name = getNoteLabel(key_color, key_index)
  		degree_selected = index+1 for note,index in current_scale when note is key_name.id
  		if degree_selected is current_scale_degree.id
  			[key_color, key_index] = parseKeyObject(root_selected)
  			midi_start = getMIDIkey(key_color, key_index)
  			playScale(key_color, key_index)
  			selectScaleDegree()
  		else
  			playFail()

  	playNote = (note, delay)->
  		MIDI.noteOn(0, note, MIDI_keys.velocity-20, delay)
  		setTimeout(()->
  			MIDI.noteOff(0, note, delay + 0.80)
  			MIDI_keys.velocity
  		)

  	playChord = (notes, delay)->
  		playNote(getMIDIkey(notes[0][0], notes[0][1]), delay)
  		playNote(getMIDIkey(notes[1][0], notes[1][1]), delay)
  		playNote(getMIDIkey(notes[2][0], notes[2][1]), delay)

  	singAlong = (song, volume)->
  		sound = document.getElementById(song)
  		sound.volumes = volume
  		sound.play()

  	playQ = ()->
  		singAlong("q_song", 0.4)

  	playB = ()->
  		singAlong("b_song", 0.4)

  	playC = ()->
  		singAlong("ceg_song", 0.4)

  	playFail = ()->
  		singAlong("the_fail_song", 0.02)

  	animate = ()->
  		window.requestAnimationFrame(animate) || window.webkitRequestAnimationFrame(animate)
  		render()

  	render = ()->
  		renderer.render(scene, camera)

  	mousedown = (event)->
  		key_played = getKeyPlayed(event)
  		if key_played isnt ''
  			pressKey(key_played, true)

  	isActive = (tabID)->
  		return true if $(tabID).attr("aria-expanded") is "true"
  		return false

  	mouseup = ()->
  		return if key_played is ''

  		if isActive("#major_scale")
  			if root_selected is null
	  			root_selected = key_played
  				current_scale = generateScale(root_selected)

  				selectScaleDegree()
  			else
  				checkScaleDegree(key_played)

  		if isActive("#practice")
  			[key_color, key_index] = parseKeyObject(key_played)
  			practice_keys.push [key_color, key_index]

  			if (practice_keys.length is 3)
	  			if checkTriad(practice_keys)
	  				selectTriad()

	  			practice_keys = []
	  			practice_chord = null

	  	releaseKey(key_played)

  	$('#keyboard').mouseover(()->

	  	if isActive("#practice")
	  		if practice_keys.length is 0
	  			selectTriad()

	  	if isActive("#major_scale")
	  		if root_selected isnt null
	  			selectScaleDegree()
	  )

  	getObject = (object)->
  		kb = child for child in scene.children when child.id is 'keyboard'
  		if object is 'keyboard'
  			return kb

  		if object is 'pointer'
  			ptr = child for child in kb.children when child.id is 'pointer'
  			return ptr

	  $('#keyboard').mouseout(()->
	  	if isActive("#major_scale")
	  		root_selected = null
	  		current_scale = []
	  		scene.remove(current_scale_degree)
	  		current_scale_degree = null
	  )

  	$('#tabs').mouseover(()->
  		if not isActive("#practice")
	  		scene.remove(current_triad_name))

  	q_song.addEventListener('mouseup', playQ, false)
  	b_song.addEventListener('mouseup', playB, false)
  	c_song.addEventListener('mouseup', playC, false)

  	screen.addEventListener('mousedown', mousedown, false)
  	screen.addEventListener('mouseup', mouseup, false)

	  createScene()
  	animate()

  # Initialize MIDI
  playingKeyboard = null
  MIDI.loadPlugin(
    soundfontUrl: "js/sound/soundfont/",
    instrument: ["acoustic_grand_piano"],
    callback: ()->
      playingKeyboard = new Keyboard()
      MIDI.loader.stop()
  )

  Event.add("body", "ready", ()->
    MIDI.loader = new widgets.Loader("Loading keyboard..."))

  # DOM test
  if RUN_TESTS
  	test("Canvas for keyboard", ()->
  		ok(document.getElementById('keyboard'), "Successfully constructed the keyboard")
  	)

  	test("WebGL element for drawing", ()->
  		ok(screen, "WebGL enabled")
  	)

)()