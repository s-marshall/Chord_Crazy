# Tests for key_geometry.js

test("sign(number) - Returns sign of number", ()->
	equal(sign(-10), -1.0, "Sign of -10 should be -1")
	ok(sign(9) is 1, "Sign of 9 should be 1")
)

test("normal(axis, direction) - Returns 3D vector", ()->
	deepEqual(normal("x", "positive"), new THREE.Vector3(1,0,0), "Positive x direction")
	deepEqual(normal("x", "negative"), new THREE.Vector3(-1,0,0), "Negative x direction")

	deepEqual(normal("y", "positive"), new THREE.Vector3(0,1,0), "Positive y direction")
	deepEqual(normal("y", "negative"), new THREE.Vector3(0,-1,0), "Negative y direction")

	deepEqual(normal("z", "positive"), new THREE.Vector3(0,0,1), "Positive z direction")
	deepEqual(normal("z", "negative"), new THREE.Vector3(0,0,-1), "Negative z direction")
)

test("getDelta(key) - Returns notch dimensions of white keys", ()->
	equal(getDelta("C"), 15, "Notch dimension for C key")
	deepEqual(getDelta("D"), [5,5], "Notch dimension for D key")
	equal(getDelta("E"), 9, "Notch dimension for E key")
	equal(getDelta("F"), 13, "Notch dimension for F key")
	deepEqual(getDelta("G"), [3,7], "Notch dimension for G key")
	deepEqual(getDelta("A"), [7,3], "Notch dimension for A key")
	equal(getDelta("B"), 11, "Notch dimension for B key")
)

test("translateOrigin(key, key_height, black_key_width) - Translates the origin of the key to the back plane (-z) as the pivot point for motion", ()->
	translation = translateOrigin("G", 60, 14)
	equal(translation[0], 10.0/3.0, "x translation for G key")
	translation = translateOrigin("C", 60, 14)
	equal(translation[0], 15.0/6.0, "x translation for C key")
	translation = translateOrigin("B", 60, 14)
	equal(translation[0], (11.0 + (24.0 - 11.0)/2.0)/3.0, "x translation for B key")
	equal(translation[1], 60.0/3.0, "y translation")
)

test("keyCenter(key) - Returns key center in the x direction", ()->
	delta = getDelta("A")
	equal(keyCenter("A"), delta[0] + (24.0 - delta[0] - delta[1])/2.0, "Returns the x coordinate for the center of A key")
	delta = getDelta("F")
	equal(keyCenter("F"), delta/2.0, "Returns the x coordinate for the center of F key")
	delta = getDelta("B")
	equal(keyCenter("B"), delta + (24.0 - delta)/2.0, "Returns the x coordinate for the center of B key")
)

