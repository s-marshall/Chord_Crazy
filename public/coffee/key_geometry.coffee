# Key geometry
sign = (n)->
	if n <= 0
		return -1.0
	else
  	return 1.0

normal = (axis, direction)->
	if axis is "x" and direction is "positive"
    return new THREE.Vector3(1,0,0)
  else if axis is "x" and direction is "negative"
  	return new THREE.Vector3(-1,0,0)
  else if axis is "y" and direction is "positive"
    return new THREE.Vector3(0,1,0)
  else if axis is "y" and direction is "negative"
    return new THREE.Vector3(0,-1,0)
  else if axis is "z" and direction is "positive"
  	return new THREE.Vector3(0,0,1)
  else
  	return new THREE.Vector3(0,0,-1)

translateOrigin = (key, key_height, black_key_width)->
  y_translation = key_height/3
  delta = getDelta(key)
  if key is "C" or key is "F"
    x_translation = (delta/2)/3
  else if key is "E" or key is "B"
    x_translation = (delta + (24 - delta)/2)/3
  else # key is D, G, or A
    x_translation = (delta[0] + black_key_width/2)/3

  return [x_translation, y_translation]

getDelta = (key)->
  return 15 if key is "C"
  return [5, 5] if key is "D"
  return 9 if key is "E"
  return 13 if key is "F"
  return [3, 7] if key is "G"
  return [7, 3] if key is "A"
  return 11 # key is B

keyCenter = (key)->
  delta = getDelta(key)
  if key is "C" or key is "F"
    return delta/2
  else if key is "B" or key is "E"
    return delta + (24 - delta)/2
  else
    return delta[0] + (24 - delta[0] - delta[1])/2

geometryOfBE = (key, key_height, black_key_height, black_key_width)->
  geometry = new THREE.Geometry()

  translation = translateOrigin(key, key_height, black_key_width)
  delta = getDelta(key)

  direction = ["negative","positive"]
  for n in [0..1]
    z_coordinate = sign(n) * 5

    geometry.vertices.push( new THREE.Vector3(-translation[0], -translation[1], z_coordinate))
    geometry.vertices.push( new THREE.Vector3(-translation[0], (key_height - black_key_height)/3 - translation[1], z_coordinate))
    geometry.vertices.push( new THREE.Vector3(delta/3 - translation[0], (key_height - black_key_height)/3 - translation[1], z_coordinate))
    geometry.vertices.push( new THREE.Vector3(delta/3 - translation[0], key_height/3 - translation[1], z_coordinate))
    geometry.vertices.push( new THREE.Vector3(8-translation[0], key_height/3 - translation[1], z_coordinate))
    geometry.vertices.push( new THREE.Vector3(8-translation[0], -translation[1], z_coordinate))

    offset = n * 6
    geometry.faces.push( new THREE.Face3(offset,2+offset,1+offset, normal("z", direction[n])))
    geometry.faces.push( new THREE.Face3(offset,5+offset,2+offset, normal("z", direction[n])))
    geometry.faces.push( new THREE.Face3(3+offset,2+offset,4+offset, normal("z", direction[n])))
    geometry.faces.push( new THREE.Face3(2+offset,5+offset,4+offset, normal("z", direction[n])))

  geometry.faces.push( new THREE.Face4(6,7,1,0, normal("x", "negative")))
  geometry.faces.push( new THREE.Face4(1,7,8,2, normal("y", "positive")))
  geometry.faces.push( new THREE.Face4(2,8,9,3, normal("x", "negative")))
  geometry.faces.push( new THREE.Face4(3,9,10,4, normal("y", "positive")))
  geometry.faces.push( new THREE.Face4(4,10,11,5, normal("x", "positive")))
  geometry.faces.push( new THREE.Face4(11,6,0,5, normal("y", "negative")))

  geometry

geometryOfCF = (key, key_height, black_key_height, black_key_width)->
  geometry = new THREE.Geometry()

  translation = translateOrigin(key, key_height, black_key_width)
  delta = getDelta(key)

  direction = ["negative","positive"]
  for n in [0..1]
    z_coordinate = sign(n) * 5

    geometry.vertices.push( new THREE.Vector3(-translation[0], -translation[1], z_coordinate))
    geometry.vertices.push( new THREE.Vector3(-translation[0], key_height/3 - translation[1], z_coordinate))
    geometry.vertices.push( new THREE.Vector3(delta/3 - translation[0], key_height/3 - translation[1], z_coordinate))
    geometry.vertices.push( new THREE.Vector3(delta/3 - translation[0], (key_height - black_key_height)/3 - translation[1], z_coordinate))
    geometry.vertices.push( new THREE.Vector3(8-translation[0], (key_height - black_key_height)/3 - translation[1], z_coordinate))
    geometry.vertices.push( new THREE.Vector3(8-translation[0], -translation[1], z_coordinate))

    offset = n * 6
    geometry.faces.push( new THREE.Face3(1+offset,0+offset,2+offset, normal("z", direction[n])))
    geometry.faces.push( new THREE.Face3(2+offset,0+offset,3+offset, normal("z", direction[n])))
    geometry.faces.push( new THREE.Face3(3+offset,0+offset,4+offset, normal("z", direction[n])))
    geometry.faces.push( new THREE.Face3(4+offset,0+offset,5+offset, normal("z", direction[n])))

  geometry.faces.push( new THREE.Face4(1,7,6,0, normal("x", "negative")))
  geometry.faces.push( new THREE.Face4(1,7,8,2, normal("y", "positive")))
  geometry.faces.push( new THREE.Face4(2,8,9,3, normal("x", "positive")))
  geometry.faces.push( new THREE.Face4(3,9,10,4, normal("y", "positive")))
  geometry.faces.push( new THREE.Face4(4,10,11,5, normal("x", "positive")))
  geometry.faces.push( new THREE.Face4(11,6,0,5, normal("y", "negative")))

  geometry

geometryOfDGA = (key, key_height, black_key_height, black_key_width)->
  geometry = new THREE.Geometry()

  translation = translateOrigin(key, key_height, black_key_width)
  delta = getDelta(key)

  direction = ["negative","positive"]
  for n in [0..1]
    z_coordinate = sign(n) * 5

    geometry.vertices.push( new THREE.Vector3(-translation[0], -translation[1], z_coordinate))
    geometry.vertices.push( new THREE.Vector3(-translation[0], (key_height - black_key_height)/3 - translation[1], z_coordinate))
    geometry.vertices.push( new THREE.Vector3(delta[0]/3 - translation[0], (key_height - black_key_height)/3 - translation[1], z_coordinate))
    geometry.vertices.push( new THREE.Vector3(delta[0]/3 - translation[0], key_height/3 - translation[1], z_coordinate))
    geometry.vertices.push( new THREE.Vector3((24-delta[1])/3 - translation[0], key_height/3 - translation[1], z_coordinate))
    geometry.vertices.push( new THREE.Vector3((24-delta[1])/3 - translation[0], (key_height - black_key_height)/3 - translation[1], z_coordinate))
    geometry.vertices.push( new THREE.Vector3(8-translation[0], (key_height - black_key_height)/3 - translation[1], z_coordinate))
    geometry.vertices.push( new THREE.Vector3(8-translation[0], -translation[1], z_coordinate))

    offset = n * 8
    geometry.faces.push( new THREE.Face3(offset,2+offset,1+offset, normal("z", direction[n])))
    geometry.faces.push( new THREE.Face3(2+offset,4+offset,3+offset, normal("z", direction[n])))
    geometry.faces.push( new THREE.Face3(offset,4+offset,2+offset, normal("z", direction[n])))
    geometry.faces.push( new THREE.Face3(offset,5+offset,4+offset, normal("z", direction[n])))
    geometry.faces.push( new THREE.Face3(offset,7+offset,5+offset, normal("z", direction[n])))
    geometry.faces.push( new THREE.Face3(5+offset,7+offset,6+offset, normal("z", direction[n])))

  geometry.faces.push( new THREE.Face4(0,8,9,1, normal("x", "negative")))
  geometry.faces.push( new THREE.Face4(1,9,10,2, normal("y", "positive")))
  geometry.faces.push( new THREE.Face4(2,10,11,3, normal("x", "negative")))
  geometry.faces.push( new THREE.Face4(11,12,4,3, normal("y", "positive")))
  geometry.faces.push( new THREE.Face4(4,12,13,5, normal("x", "positive")))
  geometry.faces.push( new THREE.Face4(5,13,14,6, normal("y", "positive")))
  geometry.faces.push( new THREE.Face4(6,14,15,7, normal("x", "positive")))
  geometry.faces.push( new THREE.Face4(15,8,0,7, normal("y", "negative")))

  geometry

blackKeyGeometry = (black_key_height, black_key_width)->
  y_translation = (black_key_height/2)/24
  x_translation = (black_key_width/2)/24
  new THREE.BeveledBlockGeometry(black_key_width/3 - x_translation, black_key_height/3 - y_translation, black_key_height/3, 1)
