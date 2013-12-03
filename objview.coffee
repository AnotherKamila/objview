view_conf =
    width:  $('#view').width()
    height: $('#view').height()
    fov:  Math.PI/2
    near: 1
    far:  10000

message = (msg) -> $('#messages').text msg

load_obj = (cb) ->
    $('#messages').css opacity: 1
    m = window.location.hash.match(/url=([^&]*)/)
    if m? and m[1]?
        url = m[1]
        $('#urlbox').val m[1]
    else
        message 'No URL specified. Append #url=<something.obj> to address.'
        return
    message "Loading OBJ file..."
    $.ajax url: url, error: (-> message "Error loading file from #{url}"), success: (data) ->
                        object = ((new THREE.OBJLoader()).parse data).children[0]
                        mesh = new THREE.SceneUtils.createMultiMaterialObject object.geometry,
                                        [ new THREE.MeshLambertMaterial(color: 0x00aaff),
                                          new THREE.MeshBasicMaterial(color: 0x0013a6, transparent: true, wireframe: true, opacity: 0.2) ]
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

    ambient_light = new THREE.AmbientLight 0x282833
    scene.add ambient_light

    grid = new THREE.SceneUtils.createMultiMaterialObject (new THREE.PlaneGeometry 2, 2, 20, 20),
                    [(new THREE.MeshBasicMaterial color: 0xaaaaaa, opacity: 0.5, transparent: true, wireframe: true),
                     (new THREE.MeshBasicMaterial color: 0xffffff, opacity: 0.3, transparent: true, side: THREE.DoubleSide)]
    scene.add grid.rotateOnAxis((new THREE.Vector3 1, 0, 0), Math.PI/2)

    scene.add mesh

    controls = new THREE.TrackballControls camera
    controls.panSpeed = 0.05
    controls.noPan = false
    controls.noZoom = false

    message 'Controls: Left mouse button: rotate, Right mouse button: pan, Wheel: zoom'
    $('#view canvas').on "click mousewheel", -> setTimeout (-> $('#messages').css opacity: 0), 1
    animate = ->
        renderer.render scene, camera
        controls.update()
        requestAnimationFrame animate
    animate()

$(window).on hashchange: -> load_obj init
$(window).trigger 'hashchange'

# $('#urlbox').on mouseenter: (-> $('#urlbox').focus()), : -> console.log "loading $('#urlbox').val()"; window.location.hash = "url=#{$('#urlbox').val()}"
$('#urlbox').on mouseenter: (-> $('#urlbox').focus()), change: -> console.log "loading $('#urlbox').val()"; window.location.hash = "url=#{$('#urlbox').val()}"
                
