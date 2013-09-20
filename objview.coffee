view_conf =
    width:  $('#view').width()
    height: $('#view').height()
    fov:  Math.PI/2
    near: 0.1
    far:  100000

message = (msg) -> $('#messages').text msg

load_obj = (cb) ->
    m = window.location.hash.match(/url=([^&]*)/)
    url = if m? and m[1]? then m[1] else 'test.obj'
    message "Loading OBJ file..."
    $.ajax url: url, error: (-> message "Error loading file from #{url}"), success: (data) ->
                        object = ((new THREE.OBJLoader()).parse data).children[0]
                        mesh = new THREE.SceneUtils.createMultiMaterialObject object.geometry,
                                        [ new THREE.MeshLambertMaterial(color: 0xaaaadd, opacity: 0.5),
                                          new THREE.MeshBasicMaterial(color: 0x002222, transparent: true, wireframe: true, opacity: 0.2) ]
                        scale = 1/mesh.children[0].geometry.boundingSphere.radius  # normalize size
                        mesh.scale = new THREE.Vector3 scale, scale, scale

                        cb mesh

init = (mesh) ->
    container = $(document.body)

    renderer = new THREE.WebGLRenderer()
    renderer.setSize view_conf.width, view_conf.height
    $('#view').append renderer.domElement

    scene = new THREE.Scene()
    window.scene = scene  # TODO remove me!

    camera = new THREE.PerspectiveCamera view_conf.fov, view_conf.width/view_conf.height, view_conf.near, view_conf.far
    camera.position.z = 100
    scene.add camera

    light = new THREE.PointLight 0xffffff
    light.position = { x: 20, y: 70, z: 150 }
    scene.add light

    grid = new THREE.SceneUtils.createMultiMaterialObject (new THREE.PlaneGeometry 2, 2, 20, 20),
                    [(new THREE.MeshBasicMaterial color: 0xcccccc, opacity: 0.6, transparent: true, wireframe: true),
                     (new THREE.MeshBasicMaterial color: 0xffffff, opacity: 0.6, transparent: true)]
    scene.add grid.rotateOnAxis((new THREE.Vector3 1, 0, 0), Math.PI/2)

    scene.add mesh

    controls = new THREE.TrackballControls camera
    controls.panSpeed = 0.05
    controls.noPan = false
    controls.noZoom = false

    animate = ->
        renderer.render scene, camera  # TODO loop via requestAnimationFrame
        controls.update()
        requestAnimationFrame animate
    message 'Controls: Left mouse button: rotate, Right mouse button: pan, Wheel: zoom'
    $('#view canvas').on "click mousewheel", -> setTimeout (-> $('#messages').css opacity: 0), 1
    animate()

load_obj init
